"""CythonPlus Backend
=================

Internal API
------------

.. autoclass:: HeaderFunction
   :members:
   :private-members:

.. autoclass:: SubBackendJITCythonPlus
   :members:
   :private-members:

.. autoclass:: CythonPlusBackend
   :members:
   :private-members:

"""
import copy
import inspect
import re
import toml

from warnings import warn

from transonic.analyses.extast import unparse, gast, FunctionDef, Name
from transonic.signatures import make_signatures_from_typehinted_func
from transonic.typing import format_type_as_backend_type, MemLayout

from .base import TypeHintRemover, format_str
from .typing import TypeFormatter

from pathlib import Path
from textwrap import indent
from typing import Iterable, Optional
import gast

# from pprint import pprint

import transonic

from transonic.analyses import extast, analyse_aot
from transonic.log import logger
from transonic.compiler import compile_extension, ext_suffix
from transonic import mpi
from transonic.mpi import PathSeq
from transonic.signatures import compute_signatures_from_typeobjects

from transonic.util import (
    has_to_build,
    format_str,
    write_if_has_to_write,
    TypeHintRemover,
    make_hex,
)

from .for_classes import make_new_code_method_from_nodes
from .typing import TypeFormatter

RE_SIGNATUE = re.compile("^\s*def .*\n", re.M)


class DecoratorFlags:
    def __init__(self, item):
        self.dic = {}
        self._parse(item)

    def __getattr__(self, name):
        return self.dic.get(name, False)

    def _parse(self, item):
        if not item:
            return
        if hasattr(item, "_transonic_keywords"):
            for k, v in item._transonic_keywords.items():
                if v:
                    self.dic[k] = True


class Config:
    def __init__(self):
        self.types = {}
        self.inits = {}
        self.load()

    def load(self):
        with open(Path(__file__).parent / "cythonplus.toml") as f:
            d = toml.load(f)
        self.types = d["types"]
        self.inits = d["initializations"]

    def init_value(self, tpe):
        return self.inits.get(tpe, tpe + "()")

    def type_conversion(self, tpe):
        return self.types.get(tpe, tpe)


CONF = Config()


class CythonPlusBackend:
    """Main class for the CythonPlus backend"""

    backend_name = "cythonplus"
    suffix_backend = ".pyx"
    suffix_header = ".pxd"
    suffix_extension = ext_suffix
    keyword_export = "cpdef"
    _SubBackendJIT = None
    needs_compilation = True

    def __init__(self):
        self.name = self.backend_name
        self.name_capitalized = self.name.capitalize()
        self.type_formatter = TypeFormatterCythonPlus(self.name)
        self.jit = None

    def _make_code_from_fdef_node(self, fdef, cyp_headers):

        parts = []
        transformed = TypeHintRemover().visit(fdef)
        # convert the AST back to source code
        doc = gast.get_docstring(transformed)
        if doc is None:
            doc = ""
        else:
            doc = f'    """{doc}\n    """\n'
            del transformed.body[0]
        new_header = (
            "\n"
            + cyp_headers["pyx"]
            + doc
            + cyp_headers["locals"]
            + "\n"
            + cyp_headers["inits"]
            + "\n"
        )
        parts.append(unparse(transformed))
        src = "\n".join(parts)
        src = RE_SIGNATUE.sub(new_header, src)
        # logger.info(src)
        return src
        # return format_str(src)

    def make_backend_files(self, paths_py, force=False, log_level=None):
        """Create backend files from a list of Python files"""

        if log_level is not None:
            logger.set_level(log_level)

        paths_out = []
        for path in paths_py:
            with open(path) as file:
                code = file.read()
            analyse = analyse_aot(code, path, self.name)
            path_out = self.make_backend_file(path, analyse, force=force)
            if path_out:
                paths_out.append(path_out)

        if paths_out:
            nb_files = len(paths_out)
            if nb_files == 1:
                conjug = "s"
            else:
                conjug = ""

            if self.needs_compilation:
                logger.warning(
                    f"{nb_files} files created or updated need{conjug}"
                    f" to be {self.name}ized"
                )

        return paths_out

    def make_backend_file(
        self, path_py: Path, analyse=None, force=False, log_level=None
    ):
        """Create a Python file from a Python file (if necessary)"""

        if log_level is not None:
            logger.set_level(log_level)
        logger.set_level("debug")
        logger.info(path_py)
        path_py = Path(path_py)

        if not path_py.exists():
            raise FileNotFoundError(f"Input file {path_py} not found")

        if path_py.absolute().parent.name == f"__{self.name}__":
            logger.debug(f"skip file {path_py}")
            return None, None, None
        if not path_py.name.endswith(".py"):
            raise ValueError(
                "transonic only processes Python file. Cannot process {path_py}"
            )

        path_dir = path_py.parent / str(f"__{self.name}__")
        path_backend = (path_dir / path_py.name).with_suffix(self.suffix_backend)

        if not has_to_build(path_backend, path_py) and not force:
            logger.warning(f"File {path_backend} already up-to-date.")
            return None, None, None

        if path_dir is None:
            return

        if not analyse:
            with open(path_py) as file:
                code = file.read()
            analyse = analyse_aot(code, path_py, self.name)

        code_pyx, codes_ext, code_pxd = self._make_backend_code(path_py, analyse)
        if not code_pyx and not code_pxd:
            logger.debug(f"no code for {self.name}\n")
            return
        logger.debug(f"code_{self.name}:\n{code_pyx}")
        logger.debug(f"code_{self.name}:\n{codes_ext}")
        logger.debug(f"code_{self.name}:\n{code_pxd}")

        for file_name, code in codes_ext["function"].items():
            path_ext_file = path_dir / (file_name + ".py")
            write_if_has_to_write(path_ext_file, format_str(code), logger.info, force)

        for file_name, code in codes_ext["class"].items():
            path_ext_file = path_dir.parent / f"__{self.name}__" / (file_name + ".py")
            write_if_has_to_write(path_ext_file, format_str(code), logger.info, force)

        if self.suffix_header:
            path_header = (path_dir / path_py.name).with_suffix(self.suffix_header)
            write_if_has_to_write(path_header, code_pxd, logger.info, force)
        logger.info(f"File {path_backend} updated")

        if code_pyx:
            written = write_if_has_to_write(path_backend, code_pyx, logger.info, force)
            if not written:
                logger.warning(f"Code in file {path_backend} already up-to-date.")
                return

        return path_backend

    def _make_first_lines_header(self):
        # return ["import cython\n\nimport numpy as np\ncimport numpy as np\n"]
        return [self._make_beginning_code()]

    def _make_beginning_code(self):
        return (
            "# distutils: language = c++\n"
            "\n"
            "# Frequently cimported:\n"
            "from libc.stdio cimport *\n"
            "\n"
            "from libcythonplus.list cimport cyplist\n"
            "from libcythonplus.dict cimport cypdict\n"
            "from libcythonplus.set cimport cypset\n"
            "\n"
            "from stdlib.string cimport Str\n"
            "from stdlib._string cimport string\n"
            "from stdlib.format cimport format\n"
            "\n"
            "\n"
        )

    def _make_backend_code(self, path_py, analyse):
        """Create a backend code from a Python file"""

        boosted_dicts, code_dependance, annotations, blocks, codes_ext = analyse
        boosted_dicts = {key: value[self.name] for key, value in boosted_dicts.items()}
        logger.info("\n".join(boosted_dicts.keys()))
        logger.info("\n".join(boosted_dicts["functions_ext"].keys()))

        lines_pyx = ["\n" + code_dependance + "\n"]
        lines_header = self._make_first_lines_header()
        # Deal with functions
        for fdef in boosted_dicts["functions"].values():
            cyp_headers = self._make_header_1_function_pxd_pyx(fdef, annotations)
            if cyp_headers:
                lines_header.append(cyp_headers["pxd"])
            code_function = self._make_code_from_fdef_node(fdef, cyp_headers)
            lines_pyx.append(code_function)

        # Deal with methods
        for klass in boosted_dicts["classes"].values():
            logger.info("KKKKKKKKK " + klass.name)
            cyp_class_definition = self._make_class_pxd(
                klass, annotations, boosted_dicts
            )
            if cyp_class_definition:
                lines_header.append(cyp_class_definition["pxd"])

        # Deal with blocks
        signatures, code_blocks = self._make_code_blocks(blocks)
        lines_pyx.extend(code_blocks)
        if signatures:
            lines_header.extend(signatures)

        code_pyx = "\n".join(lines_pyx).strip()

        if code_pyx:
            code_pyx = self._make_beginning_code() + code_pyx
            self._append_line_header_variable(lines_header, "__transonic__")
            code_pyx += f"\n\n__transonic__ = ('{transonic.__version__}',)"

        # return format_str(code), codes_ext, "\n".join(lines_header).strip() + "\n"
        code_pxd = "\n".join(lines_header).strip() + "\n"
        return code_pyx, codes_ext, code_pxd

    def _append_line_header_variable(self, lines_header, name_variable):
        pass

    def _make_code_blocks(self, blocks):
        code = []
        signatures_blocks = []
        for block in blocks:

            str_variables = ", ".join(block.signatures[0].keys())
            fdef_block = extast.gast.parse(
                f"""def {block.name}({str_variables}):pass"""
            ).body[0]

            # TODO: locals_types for blocks
            locals_types = None
            sb = self._make_header_from_fdef_annotations(
                fdef_block, block.signatures, locals_types
            )
            signatures_blocks.extend(sb)

            code.append(f"\ndef {block.name}({str_variables}):\n")
            code.append(indent(extast.unparse(block.ast_code), "    "))
            if block.results:
                code.append(f"    return {', '.join(block.results)}\n")

        arguments_blocks = {
            block.name: list(block.signatures[0].keys()) for block in blocks
        }

        if arguments_blocks:
            self._append_line_header_variable(signatures_blocks, "arguments_blocks")
            code.append(f"arguments_blocks = {str(arguments_blocks)}\n")
        return signatures_blocks, code

    def _make_code_method(
        self, class_name, fdef, meth_name, annotations, boosted_dicts
    ):
        class_def = boosted_dicts["classes"][class_name]

        if class_name in annotations["classes"]:
            annotations_class = annotations["classes"][class_name]
        else:
            annotations_class = {}
        logger.info("ac " + str(annotations["classes"]))

        if (class_name, meth_name) in annotations["methods"]:
            annotations_meth = annotations["methods"][(class_name, meth_name)]
        else:
            annotations_meth = {}

        meth_name = fdef.name
        python_code, attributes, _ = make_new_code_method_from_nodes(class_def, fdef)

        for attr in attributes:
            logger.info("=> " + attr)

        for attr in attributes:
            if attr not in annotations_class:
                raise NotImplementedError(
                    f"self.{attr} used but {attr} not in class annotations"
                )
        types_attrs = {"self_" + attr: annotations_class[attr] for attr in attributes}
        types_pythran = {**types_attrs, **annotations_meth}

        # TODO: locals_types for methods
        locals_types = None
        signatures_method = self._make_header_from_fdef_annotations(
            extast.parse(python_code).body[0], [types_pythran], locals_types
        )

        str_self_dot_attributes = ", ".join("self." + attr for attr in attributes)
        args_func = [arg.id for arg in fdef.args.args[1:]]
        str_args_func = ", ".join(args_func)

        defaults = fdef.args.defaults
        nb_defaults = len(defaults)
        nb_args = len(fdef.args.args)
        nb_no_defaults = nb_args - nb_defaults - 1

        str_args_value_func = []
        ind_default = 0
        for ind, arg in enumerate(fdef.args.args[1:]):
            name = arg.id
            if ind < nb_no_defaults:
                str_args_value_func.append(f"{name}")
            else:
                default = extast.unparse(defaults[ind_default]).strip()
                str_args_value_func.append(f"{name}={default}")
                ind_default += 1

        str_args_value_func = ", ".join(str_args_value_func)

        if str_self_dot_attributes:
            str_args_backend_func = ", ".join((str_self_dot_attributes, str_args_func))
        else:
            str_args_backend_func = str_args_func

        name_var_code_new_method = f"__code_new_method__{class_name}__{meth_name}"

        self._append_line_header_variable(signatures_method, name_var_code_new_method)
        python_code += (
            f'\n{name_var_code_new_method} = """\n\n'
            f"def new_method(self, {str_args_value_func}):\n"
            f"    return backend_func({str_args_backend_func})"
            '\n\n"""\n'
        )

        return signatures_method, format_str(python_code)

    def _make_header_from_fdef_annotations(
        self, fdef, annotations: dict, locals_types=None, returns=None
    ):

        flags = DecoratorFlags(fdef)
        inline = "inline " if flags.inline else ""

        fdef = FunctionDef(name=fdef.name, args=copy.deepcopy(fdef.args), body=[])

        assert isinstance(annotations, list)

        if len(annotations) > 1:
            warn(
                "CythoPlus backend only supports one set of annotations. "
                "(And CythonPlus does not supports fused types.)"
            )

        try:
            annotations = annotations[0]
        except IndexError:
            annotations = {}

        transonic_types = set(annotations.values())

        if locals_types:
            transonic_types.update(locals_types.values())

        if returns:
            transonic_types.add(returns)

        transonic_types = sorted(transonic_types, key=repr)

        template_parameters = set()
        for ttype in transonic_types:
            if hasattr(ttype, "get_template_parameters"):
                template_parameters.update(ttype.get_template_parameters())

        template_parameters = sorted(template_parameters, key=repr)

        # transonic_fused_types = [
        #     ttype
        #     for ttype in transonic_types
        #     if hasattr(ttype, "is_fused_type") and ttype.is_fused_type()
        # ]

        if not all(param.values for param in template_parameters):
            raise ValueError(
                f"{template_parameters}, {[param.values for param in template_parameters]}"
            )

        # cythonplus does not use fused types (currently).
        # cython_fused_types = {}

        def get_ttype_name(ttype):
            if hasattr(ttype, "short_repr"):
                ttype_name = ttype.short_repr()
            elif hasattr(ttype, "__name__"):
                ttype_name = ttype.__name__
            elif isinstance(ttype, str):
                ttype_name = ttype
            else:
                raise RuntimeError
            return ttype_name

        # for ttype in transonic_fused_types:
        #     ttype_name = get_ttype_name(ttype)
        #     name_cython_type = f"__{fdef.name}__{ttype_name}"
        #
        #     cython_types = ttype.get_all_formatted_backend_types(self.type_formatter)
        #     if "None" in cython_types:
        #         cython_types.remove("None")
        #     cython_fused_types[name_cython_type] = cython_types

        signatures_func = []

        # for name, possible_types in cython_fused_types.items():
        #     ctypedef = [f"ctypedef fused {name}:\n"]
        #     for possible_type in sorted(set(possible_types)):
        #         ctypedef.append(f"   {possible_type}\n")
        #     signatures_func.append("".join(ctypedef))

        def get_name_cython_type(ttype):
            return format_type_as_backend_type(ttype, self.type_formatter)

        # change function parameters
        if fdef.args.defaults:
            name_start = Name("*", gast.Param())
            fdef.args.defaults = [name_start] * len(fdef.args.defaults)
        for name in fdef.args.args:
            name.annotation = None
            if annotations:
                ttype = annotations[name.id]
                name_cython_type = get_name_cython_type(ttype)
            else:
                name_cython_type = "object"
            name.id = f"{name_cython_type} {name.id}"

        if locals_types is not None and locals_types:
            # note: np.ndarray not supported by Cython in "locals"
            # TODO: thus, fused types not supported here
            locals_types = ", ".join(
                f"{k}={format_type_as_backend_type(v, self.type_formatter, memview=True)}"
                for k, v in locals_types.items()
            )
            # signatures_func.append(f"@cython.locals({locals_types})")

        if returns is not None:
            ttype = returns
            name_cython_type = get_name_cython_type(ttype)
            returns = name_cython_type + " "
        else:
            returns = ""

        def_keyword = "cpdef"
        signatures_func.append(
            f"{def_keyword} {inline}{returns}{unparse(fdef).strip()[4:-1]}\n"
        )
        return signatures_func

    def _make_header_from_fdef_annotations_pxd_pyx(
        self, fdef, annotations: dict, locals_types=None, returns=None
    ):

        result = {"pyx": "", "pxd": "", "locals": "", "inits": ""}
        flags = DecoratorFlags(fdef)
        nogil = " nogil" if flags.nogil else ""
        inline = " inline" if flags.inline else ""

        fdef = FunctionDef(name=fdef.name, args=copy.deepcopy(fdef.args), body=[])

        assert isinstance(annotations, list)

        if len(annotations) > 1:
            warn(
                "CythoPlus backend only supports one set of annotations. "
                "(And CythonPlus does not supports fused types.)"
            )

        try:
            annotations = annotations[0]
        except IndexError:
            annotations = {}

        transonic_types = set(annotations.values())

        if locals_types:
            transonic_types.update(locals_types.values())

        if returns:
            transonic_types.add(returns)

        transonic_types = sorted(transonic_types, key=repr)

        template_parameters = set()
        for ttype in transonic_types:
            if hasattr(ttype, "get_template_parameters"):
                template_parameters.update(ttype.get_template_parameters())

        template_parameters = sorted(template_parameters, key=repr)

        # transonic_fused_types = [
        #     ttype
        #     for ttype in transonic_types
        #     if hasattr(ttype, "is_fused_type") and ttype.is_fused_type()
        # ]

        if not all(param.values for param in template_parameters):
            raise ValueError(
                f"{template_parameters}, {[param.values for param in template_parameters]}"
            )

        # cython_fused_types = {}

        def get_ttype_name(ttype):
            if hasattr(ttype, "short_repr"):
                ttype_name = ttype.short_repr()
            elif hasattr(ttype, "__name__"):
                ttype_name = ttype.__name__
            elif isinstance(ttype, str):
                ttype_name = ttype
            else:
                raise RuntimeError
            return ttype_name

        # for ttype in transonic_fused_types:
        #     ttype_name = get_ttype_name(ttype)
        #     name_cython_type = f"__{fdef.name}__{ttype_name}"
        #
        #     cython_types = ttype.get_all_formatted_backend_types(self.type_formatter)
        #     if "None" in cython_types:
        #         cython_types.remove("None")
        #     cython_fused_types[name_cython_type] = cython_types

        ###
        ### cythonplus does not support fused types
        ###

        # signatures_func = []

        # for name, possible_types in cython_fused_types.items():
        #     ctypedef = [f"ctypedef fused {name}:\n"]
        #     for possible_type in sorted(set(possible_types)):
        #         ctypedef.append(f"   {possible_type}\n")
        #     signatures_func.append("".join(ctypedef))

        def get_name_cython_type(ttype):
            return format_type_as_backend_type(ttype, self.type_formatter)

        def init_cythonplus_type(ttype):
            return CONF.init_value(get_name_cython_type(ttype))

        # change function parameters
        pxd_args = copy.deepcopy(fdef.args)
        if pxd_args.defaults:
            name_start = Name("*", gast.Param())
            pxd_args.defaults = [name_start] * len(pxd_args.defaults)
        for name in pxd_args.args:
            name.annotation = None
            if annotations:
                ttype = annotations[name.id]
                name_cython_type = get_name_cython_type(ttype)
            else:
                name_cython_type = "object"
            # name.id = f"{name_cython_type} {name.id}"  # for pyx
            name.id = f"{name_cython_type}"  # for .pxd

        if fdef.args.defaults:
            name_start = Name("*", gast.Param())
            fdef.args.defaults = [name_start] * len(fdef.args.defaults)
        for name in fdef.args.args:
            name.annotation = None
            if annotations:
                ttype = annotations[name.id]
                name_cython_type = get_name_cython_type(ttype)
            else:
                name_cython_type = "object"
            name.id = f"{name_cython_type} {name.id}"  # for pyx
            # name.id = f"{name_cython_type}"  # for .pxd

        if locals_types:
            # note: np.ndarray not supported by Cython in "locals"
            # TODO: thus, fused types not supported here
            # locals_types = ", ".join(
            #     f"{k}={format_type_as_backend_type(v, self.type_formatter, memview=True)}"
            #     for k, v in locals_types.items()
            # )
            locals = [
                f"    cdef {get_name_cython_type(v)} {k}\n"
                for k, v in locals_types.items()
            ]
            inits = [
                f"    {k} = {init_cythonplus_type(v)}\n"
                for k, v in locals_types.items()
            ]
            result["locals"] = "".join(locals)
            result["inits"] = "".join(inits)
            # logger.info(result["locals"])

        if returns is not None:
            ttype = returns
            name_cython_type = get_name_cython_type(ttype)
            returns = name_cython_type + " "
        else:
            returns = "void "

        # logger.info(unparse(fdef))
        result["pyx"] = f"cdef {inline}{returns}{unparse(fdef).strip()[4:-1]}{nogil}:\n"
        fdef.args = pxd_args
        result["pxd"] = f"cdef {inline}{returns}{unparse(fdef).strip()[4:-1]}{nogil}"

        return result

    def name_ext_from_path_backend(self, path_backend):
        """Return an extension name given the path of a Pythran file"""

        name = None
        path_backend = Path(path_backend)
        if path_backend.exists():
            with open(path_backend) as file:
                src = file.read()
            # quick fix to recompile when the header has been changed
            for suffix in (".pythran", ".pxd"):
                path_header = path_backend.with_suffix(suffix)
                if path_header.exists():
                    with open(path_header) as file:
                        src += file.read()

            name = path_backend.stem + "_" + make_hex(src) + self.suffix_extension

        return name

    def check_if_compiled(self, module):
        return False

    def compile_extension(
        self,
        path_backend,
        name_ext_file=None,
        native=False,
        xsimd=False,
        openmp=False,
        str_accelerator_flags: Optional[str] = None,
        parallel=True,
        force=True,
    ):
        raise NotImplementedError

    def _make_header_1_function_pxd_pyx(self, fdef, annotations):

        logger.info("fac " + str(annotations))

        try:
            annots = annotations["__in_comments__"][fdef.name]
        except KeyError:
            annots = []

        try:
            annot = annotations["functions"][fdef.name]
        except KeyError:
            pass
        else:
            annots.append(annot)

        locals_types = annotations["__locals__"].get(fdef.name, None)
        returns = annotations["__returns__"].get(fdef.name, None)

        return self._make_header_from_fdef_annotations_pxd_pyx(
            fdef, annots, locals_types, returns
        )

    def _make_class_pxd(self, klass, annotations, boosted_dicts):
        name = klass.name
        result = {"pyx": "", "pxd": ""}
        flags = DecoratorFlags(klass)
        activable = " activable" if flags.activable else ""

        lines = []
        lines.append(f"cdef cypclass {name}{activable}:\n")

        for (class_name, meth_name), fdef in boosted_dicts["methods"].items():
            logger.info("=========== " + class_name + " / " + meth_name)
            if class_name != name:
                continue
            signatures, code_for_meth = self._make_code_method(
                class_name, fdef, meth_name, annotations, boosted_dicts
            )
            logger.info("=========== " + meth_name)
            lines.append(code_for_meth)
            lines.extend(signatures)

        result["pxd"] = "".join(lines)
        logger.info(result["pxd"])
        return result

        # try:
        #     annots = annotations["__in_comments__"][name]
        # except KeyError:
        #     annots = []
        # try:
        #     annot = annotations["functions"][name]
        # except KeyError:
        #     pass
        # else:
        #     annots.append(annot)
        #
        # locals_types = annotations["__locals__"].get(name, None)
        # # returns = annotations["__returns__"].get(name, None)
        # #
        # logger.info(annots)
        # logger.info(locals_types)
        # # return self._make_header_from_fdef_annotations_pxd_pyx(
        # #     fdef, annots, locals_types, returns
        # # )


def normalize_type_name_for_array(name):
    # if name == "bool_":
    #     return "np.uint8"
    # if any(name.endswith(str(number)) for number in (8, 16, 32, 64, 128)):
    #     return "np." + name
    # if name in ("int", "float", "complex"):
    #     return "np." + name
    return name


class TypeFormatterCythonPlus(TypeFormatter):
    def normalize_type_name(self, name):
        # if any(name.endswith(str(number)) for number in (8, 16, 32, 64, 128)):
        #     return "np." + name + "_t"
        # if name in ("int", "float", "complex", "str"):
        #     return f"cython.{name}"
        return CONF.type_conversion(name)

    def make_array_code(
        self, dtype, ndim, shape, memview, mem_layout, positive_indices
    ):
        dtype = normalize_type_name_for_array(dtype.__name__)
        if ndim == 0:
            return dtype

        if memview:
            return memoryview_type(dtype, ndim, mem_layout)
        else:
            return np_ndarray_type(dtype, ndim, mem_layout, positive_indices)

    def make_dict_code(self, type_keys, type_values, **kwargs):
        return "dict"

    def make_set_code(self, type_keys, **kwargs):
        return "set"

    def make_list_code(self, type_elem, **kwargs):
        return "list"

    def make_tuple_code(self, types, **kwargs):
        return "tuple"

    def make_const_code(self, code):
        return "const " + code


def memoryview_type(dtype, ndim, mem_layout) -> str:
    ndim_F = 0
    ndim_C = 0
    if mem_layout is MemLayout.C:
        ndim_C = 1
        ndim -= 1
    elif mem_layout is MemLayout.F:
        ndim_F = 1
        ndim -= 1
    end = ", ".join(["::1"] * ndim_F + [":"] * ndim + ["::1"] * ndim_C)
    return f"{dtype}_t[{end}]"


def np_ndarray_type(dtype, ndim, mem_layout, positive_indices) -> str:
    if mem_layout is MemLayout.C:
        mode = ', mode="c"'
    elif mem_layout is MemLayout.F:
        mode = ', mode="f"'
    else:
        mode = ""

    if positive_indices:
        positive_indices = ", negative_indices=False"
    else:
        positive_indices = ""

    return f"np.ndarray[{dtype}_t, ndim={ndim}{mode}{positive_indices}]"


class HeaderFunction:
    def __init__(
        self,
        path=None,
        name=None,
        arguments=None,
        types: dict = None,
        imports=None,
    ):

        if path is not None:
            self.path = path
            with open(path) as file:
                lines = file.readlines()

            last_line = lines[-1]
            assert last_line.startswith("cpdef ")
            name = last_line.split(" ", 1)[1].split("(", 1)[0]

            parts = [
                part.strip() for part in "".join(lines[:-1]).split("ctypedef fused ")
            ]
            imports = parts[0]

            types = {}

            for part in parts[1:]:
                assert part.startswith(f"__{name}_")
                lines = part.split("\n")
                arg_name = lines[0].split(f"__{name}_", 1)[1].split(":", 1)[0]
                types[arg_name] = set(line.strip() for line in lines[1:])

        if types is None:
            if arguments is None:
                raise ValueError
            types = {key: set() for key in arguments}

        if arguments is None:
            arguments = types.keys()

        self.arguments = arguments
        self.name = name
        self.types = types
        self.imports = imports

    def make_code(self):

        bits = [self.imports + "\n\n"]

        for arg, types in self.types.items():
            bits.append(f"ctypedef fused __{self.name}_{arg}:\n")
            for type_ in sorted(types):
                bits.append(f"    {type_}\n")
            bits.append("\n")

        tmp = ", ".join(f"__{self.name}_{arg} {arg}" for arg in self.types)
        bits.append(f"cpdef {self.name}({tmp})")
        code = "".join(bits)
        return code

    def add_signature(self, new_types):
        for new_type, set_types in zip(new_types, self.types.values()):
            set_types.add(new_type)

    def update_with_other_header(self, other):
        if self.name != other.name:
            raise ValueError
        if self.types.keys() != other.types.keys():
            raise ValueError
        for key, value in other.types.items():
            self.types[key].update(value)
