"""CythonPlus Backend
=================

Internal API
------------

.. autoclass:: CythonPlusBackend
   :members:
   :private-members:

"""
import re
from copy import deepcopy
from pathlib import Path
from textwrap import indent
from typing import Optional
from warnings import warn

import toml
import transonic
from transonic.analyses import analyse_aot
from transonic.analyses.extast import FunctionDef, Name, gast, unparse
from transonic.compiler import ext_suffix
from transonic.log import logger
from transonic.typing import MemLayout
from transonic.util import (
    TypeHintRemover,
    format_str,
    has_to_build,
    make_hex,
    write_if_has_to_write,
)

RE_SIGNATURE = re.compile("^\s*def .*\n", re.M)
TAB = "    "


def tab(indent_level):
    return TAB * indent_level


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
        user_conf = Path.home() / "cythonplus.toml"
        if user_conf.exists():
            with open(user_conf) as f:
                d2 = toml.load(f)
                d.update(d2)
        self.types = d["types"]
        self.inits = d["initializations"]

    def init_value(self, tpe):
        return self.inits.get(tpe, tpe + "()")

    def type_conversion(self, tpe):
        if tpe in self.types:
            return self.types[tpe]
        if tpe.startswith("typing."):
            tpe = tpe[7:]
        if tpe in self.types:
            return self.types[tpe]
        tpe = tpe.replace(" ", "")
        return self.types.get(tpe, tpe)


CONF = Config()


def cythonplus_type(tpe):
    """Format a Transonic type as a backend (Pythran, Cython, ...) type"""
    if tpe is None:
        # None has a special meaning for typing...
        return "None"
    if hasattr(tpe, "__name__"):
        backend_type = tpe.__name__
    elif hasattr(tpe, "__str__"):
        backend_type = str(tpe)
    else:
        raise RuntimeError(f"strange type: {tpe}")
    return CONF.type_conversion(backend_type)


def cythonplus_initializer(cython_type):
    return CONF.init_value(cythonplus_type(cython_type))


class FunctionAnnotations:
    def __init__(self, function_name, annotations):
        self.func_key = function_name
        self.functions = annotations["functions"].get(self.func_key) or {}
        if not self.functions:
            self.functions = annotations["__in_comments__"].get(self.func_key) or {}
        self.locals = annotations["__locals__"].get(self.func_key) or {}
        self.returns = annotations["__returns__"].get(self.func_key) or None

        transonic_types = set(self.functions.values())
        transonic_types.update(self.locals.values())
        if self.returns:
            transonic_types.add(self.returns)
        self.transonic_types = sorted(transonic_types, key=repr)

    def args(self, name_id):
        return self.functions.get(name_id, "")


class MethodAnnotations:
    def __init__(self, class_name, meth_name, annotations):
        self.meth_key = (class_name, meth_name)
        self.classes = annotations["classes"].get(class_name) or {}
        self.methods = annotations["methods"].get(self.meth_key) or {}
        self.locals = annotations["__locals__"].get(self.meth_key) or {}
        self.returns = annotations["__returns__"].get(self.meth_key) or None

        transonic_types = set(self.methods.values())
        transonic_types.update(self.locals.values())
        if self.returns:
            transonic_types.add(self.returns)
        self.transonic_types = sorted(transonic_types, key=repr)

    def args(self, name_id):
        return self.methods.get(name_id, "")


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
        self.type_formatter = None
        self.jit = None

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

        return paths_out

    def make_backend_file(
        self, path_py: Path, analyse=None, force=False, log_level=None
    ):
        """Create a CythonPlus file from a Python file (if necessary)"""
        logger.set_level("debug")
        if log_level is not None:
            logger.set_level(log_level)
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
        # logger.debug(f"code_{self.name}:\n{code_pyx}")
        # logger.debug(f"code_{self.name}:\n{codes_ext}")
        # logger.debug(f"code_{self.name}:\n{code_pxd}")

        for file_name, code in codes_ext["function"].items():
            path_ext_file = path_dir / (file_name + ".py")
            write_if_has_to_write(path_ext_file, format_str(code), logger.info, force)

        for file_name, code in codes_ext["class"].items():
            path_ext_file = path_dir.parent / f"__{self.name}__" / (file_name + ".py")
            write_if_has_to_write(path_ext_file, format_str(code), logger.info, force)

        if code_pxd:
            path_header = (path_dir / path_py.name).with_suffix(self.suffix_header)
            write_if_has_to_write(path_header, code_pxd, logger.info, force)

        if code_pyx:
            write_if_has_to_write(path_backend, code_pyx, logger.info, force)

        return path_backend

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
        else:
            src = ""
        name = path_backend.stem + "_" + make_hex(src) + self.suffix_extension
        return name

    def check_if_compiled(self, module):
        return False

    def _make_first_lines_header(self):
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
        )

    def _make_backend_code(self, path_py, analyse):
        """Create a backend code from a Python file"""
        boosted_dicts, code_dependance, annotations, blocks, codes_ext = analyse
        boosted_dicts = {key: value[self.name] for key, value in boosted_dicts.items()}

        lines_pyx = []
        if code_dependance:
            lines_pyx.append(
                "\n#### WARNING: some cythonplus code depends on this python code:"
            )
            lines_pyx.append(code_dependance)
            lines_pyx.append("####\n")

        lines_header = self._make_first_lines_header()

        # Deal with functions
        for fdef in boosted_dicts["functions"].values():
            func_annotations = FunctionAnnotations(fdef.name, annotations)
            cyp_headers = self._make_header_function_pxd_pyx(fdef, func_annotations)
            if cyp_headers:
                lines_header.append(cyp_headers["pxd"])
            code_function = self._make_code_from_fdef_node(
                fdef, cyp_headers, None, "", 0
            )
            lines_pyx.append(code_function)

        # Deal with methods
        for klass in boosted_dicts["classes"].values():
            self._make_cypclass(klass, annotations, boosted_dicts, lines_header)

        # Deal with blocks
        if blocks:
            logger.warn("Blocks are ignored.")

        if lines_pyx:
            code_pyx = "\n".join(lines_pyx).strip()
            if not code_dependance:
                code_pyx = "\n" + code_pyx
            code_pyx = self._make_beginning_code() + code_pyx
            code_pyx += f"\n\n\n__transonic__ = ('{transonic.__version__}',)"
        else:
            code_pyx = None

        if lines_header:
            code_pxd = "\n".join(lines_header).strip() + "\n"
        else:
            code_pxd = None

        return code_pyx, codes_ext, code_pxd

    def _make_cypclass(self, klass, annotations, boosted_dicts, lines_header):
        result = {"pyx": "", "pxd": ""}
        flags = DecoratorFlags(klass)
        activable = " activable" if flags.activable else ""
        lines = self._cypclass_initialisation(klass, annotations, activable)

        for (class_name, meth_name), fdef in boosted_dicts["methods"].items():
            if class_name != klass.name:
                continue
            code_for_meth = self._make_code_method(
                class_name, fdef, annotations, boosted_dicts, activable
            )
            lines.append(code_for_meth)

        result["pxd"] = "".join(lines) + "\n"
        # logger.info(result["pxd"])
        lines_header.append(result["pxd"])
        return result

    def _cypclass_initialisation(self, klass, annotations, activable):
        lines = []
        lines.append(f"cdef cypclass {klass.name}{activable}:\n")
        cls_annotation = annotations["classes"].get(klass.name) or {}
        for item in cls_annotation.items():
            attr, ttype = item
            name_cython_type = cythonplus_type(ttype)
            lines.append(f"{TAB}{name_cython_type} {attr}\n")
        return lines

    def _make_code_method(
        self, class_name, fdef, annotations, boosted_dicts, activable
    ):
        meth_name = fdef.name
        class_def = boosted_dicts["classes"][class_name]
        meth_annotations = MethodAnnotations(class_name, meth_name, annotations)
        cyp_headers = self._header_from_class_annotations_cypclass(
            fdef,
            meth_annotations,
        )
        return self._make_code_from_fdef_node(
            fdef, cyp_headers, meth_annotations, activable, 1
        )

    def _make_header_function_pxd_pyx(self, fdef, func_annotations):
        tab0 = tab(0)
        tab1 = tab(1)
        result = {"pyx": "", "pxd": "", "locals": "", "inits": ""}
        flags = DecoratorFlags(fdef)
        nogil = " nogil" if flags.nogil else ""
        inline = " inline" if flags.inline else ""

        fdef = FunctionDef(name=fdef.name, args=deepcopy(fdef.args), body=[])

        template_parameters = set()
        for ttype in func_annotations.transonic_types:
            if hasattr(ttype, "get_template_parameters"):
                template_parameters.update(ttype.get_template_parameters())
        template_parameters = sorted(template_parameters, key=repr)

        if not all(param.values for param in template_parameters):
            raise ValueError(
                f"{template_parameters}, {[param.values for param in template_parameters]}"
            )

        # change function parameters
        pxd_args = deepcopy(fdef.args)
        if pxd_args.defaults:
            name_start = Name("*", gast.Param())
            pxd_args.defaults = [name_start] * len(pxd_args.defaults)
        for name in pxd_args.args:
            name.annotation = None
            ttype = func_annotations.args(name.id)
            if ttype:
                name_cython_type = cythonplus_type(ttype)
            else:
                name_cython_type = "object"
            name.id = f"{name_cython_type}"  # for .pxd

        if fdef.args.defaults:
            name_start = Name("*", gast.Param())
            fdef.args.defaults = [name_start] * len(fdef.args.defaults)
        for name in fdef.args.args:
            name.annotation = None
            ttype = func_annotations.args(name.id)
            if ttype:
                name_cython_type = cythonplus_type(ttype)
            else:
                name_cython_type = "object"
            name.id = f"{name_cython_type} {name.id}"  # for pyx

        if func_annotations.locals:
            locals = [
                f"{tab1}cdef {cythonplus_type(v)} {k}\n"
                for k, v in func_annotations.locals.items()
            ]
            inits = [
                f"{tab1}{k} = {cythonplus_initializer(v)}\n"
                for k, v in func_annotations.locals.items()
            ]
            result["locals"] = "".join(locals)
            result["inits"] = "".join(inits)
            # logger.info(result["locals"])

        if func_annotations.returns:
            returns = cythonplus_type(func_annotations.returns) + " "
        else:
            returns = "void "

        # logger.info(unparse(fdef))
        result[
            "pyx"
        ] = f"{tab0}cdef {inline}{returns}{unparse(fdef).strip()[4:-1]}{nogil}:\n"
        fdef.args = pxd_args
        result[
            "pxd"
        ] = f"{tab0}cdef {inline}{returns}{unparse(fdef).strip()[4:-1]}{nogil}"

        return result

    def _header_from_class_annotations_cypclass(
        self,
        fdef,
        meth_annotations,
    ):
        """make header of a cypclass method"""
        tab1 = tab(1)
        tab2 = tab(2)
        result = {"pyx": "", "pxd": "", "locals": "", "inits": ""}

        fdef = FunctionDef(name=fdef.name, args=deepcopy(fdef.args), body=[])

        template_parameters = set()
        for ttype in meth_annotations.transonic_types:
            if hasattr(ttype, "get_template_parameters"):
                template_parameters.update(ttype.get_template_parameters())
        template_parameters = sorted(template_parameters, key=repr)

        if not all(param.values for param in template_parameters):
            raise ValueError(
                f"{template_parameters}, {[param.values for param in template_parameters]}"
            )

        if fdef.args.defaults:
            name_start = Name("*", gast.Param())
            fdef.args.defaults = [name_start] * len(fdef.args.defaults)
        for name in fdef.args.args:
            name.annotation = None
            if name.id == "self":
                name_cython_type = ""
            else:
                ttype = meth_annotations.args(name.id)
                if ttype:
                    name_cython_type = cythonplus_type(ttype)
                else:
                    name_cython_type = "object"
            if name_cython_type:
                name_cython_type += " "
            name.id = f"{name_cython_type}{name.id}"

        if meth_annotations.locals:
            locals = [
                f"{tab2}cdef {cythonplus_type(v)} {k}\n"
                for k, v in meth_annotations.locals.items()
            ]
            inits = [
                f"{tab2}{k} = {cythonplus_initializer(v)}\n"
                for k, v in meth_annotations.locals.items()
            ]
            result["locals"] = "".join(locals)
            result["inits"] = "".join(inits)
            # logger.info(result["locals"])

        if fdef.name == "__init__":
            returns = ""
        else:
            if meth_annotations.returns:
                returns = cythonplus_type(meth_annotations.returns) + " "
            else:
                returns = "void "

        # logger.info(unparse(fdef))
        # for cypclass method, pyx == pxd
        result["pyx"] = f"{tab1}{returns}{unparse(fdef).strip()[4:-1]}:\n"
        return result

    def _make_code_from_fdef_node(
        self, fdef, cyp_headers, meth_annotations, activable, indent_level
    ):
        tab0 = tab(indent_level)
        tab1 = tab(indent_level + 1)
        parts = []
        transformed = TypeHintRemover().visit(fdef)
        # convert the AST back to source code
        doc = gast.get_docstring(transformed)
        if doc is None:
            doc = ""
        else:
            doc = f'{tab1}"""{doc}\n{tab1}"""\n'
            del transformed.body[0]

        tabbed_locals = cyp_headers["locals"].split("\n")
        new_header = "\n" + cyp_headers["pyx"] + doc
        if cyp_headers["locals"]:
            new_header = new_header + cyp_headers["locals"]
        if cyp_headers["inits"]:
            new_header = new_header + cyp_headers["inits"] + "\n"

        if fdef.name == "__init__":
            if activable:
                new_header += (
                    f"{tab1}# for activable cypclass defaults:\n"
                    f"{tab1}self._active_result_class = NullResult\n"
                    f"{tab1}self._active_queue_class = "
                    f"consume SequentialMailBox(scheduler)\n"
                )
            if meth_annotations and meth_annotations.classes:
                new_header += f"{tab1}# Default initialization of attributes:\n"
                for item in meth_annotations.classes.items():
                    attr, ttype = item
                    new_header += (
                        f"{tab1}self.{attr} = {cythonplus_initializer(ttype)}\n"
                    )
                new_header += "\n"

        parts.append(indent(unparse(transformed), tab0))
        src = "\n".join(parts) + "\n"
        src = RE_SIGNATURE.sub(new_header, src)
        # logger.info(src)
        return src
