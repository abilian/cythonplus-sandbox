# distutils: language = c++

# golomb sequence
from libcythonplus.list cimport cyplist
from runtime.runtime cimport SequentialMailBox, BatchMailBox, NullResult, Scheduler
from cython.operator cimport address


# ctypedef cyplist[Golomb] Glist
ctypedef cyplist[long] Longlist


cdef cypclass Golomb activable:
    long rank
    long value
    Longlist results

    __init__(self, lock Scheduler scheduler, long rank):
        self._active_result_class = NullResult
        self._active_queue_class = consume BatchMailBox(scheduler)
        self.rank = rank
        self.value = 0
        self.results = NULL


    void set_list(self, Longlist lst):
        self.results = lst


    long g(self, long n):  # better with external function ?
        if n == 1:
            return 1
        return self.g(n - self.g(self.g(n - 1))) + 1


    void compute(self):#, Glist lst):
        self.value = self.g(self.rank)
        if self.results is not NULL:
            self.results[self.rank] = self.value


# cdef Glist golomb_sequence(long size) nogil:
cdef Longlist golomb_sequence(long size) nogil:
    # cdef Glist lst
    cdef lock Scheduler scheduler
    cdef Longlist results

    # lst = Glist()
    results = Longlist()

    with nogil:
        for i in range(1, size+1):
            g = Golomb(scheduler, i)
            g.set_list(results)
            ag = <active Golomb> consume g
            ag.compute(NULL)
            # ag.compute(NULL, lst)
        scheduler.finish()
    # return lst
    return results


cdef py_golomb_sequence(long size):
    # cdef Glist glist
    cdef Longlist results

    with nogil:
        results = golomb_sequence(size)
    # return [(g.rank, g.value) for g in glist]
    return [(i, results[i]) for i in range(1, size+1)]


def main():
    print(py_golomb_sequence(50))

# Error compiling Cython file:
# ------------------------------------------------------------
# ...
#     lst = Glist()
#
#     with nogil:
#         for i in range(1, size+1):
#             g = Golomb(scheduler, i)
#             g.set_list(address(lst))
#                       ^
# ------------------------------------------------------------
#
# golomb.pyx:49:23: Cannot take address of cypclass
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1277, in cythonize_one
#     raise CompileError(None, pyx_file)
# Cython.Compiler.Errors.CompileError: golomb.pyx
# jd@fuseki:~/abi/cythonplus-sandbox/exemples/golomb_cyplus_multicore$
#

#
# Error compiling Cython file:
# ------------------------------------------------------------
# ...
#     lst = Glist()
#
#     with nogil:
#         for i in range(1, size+1):
#             g = Golomb(scheduler, i)
#             g.set_list(&lst)
#                       ^
# ------------------------------------------------------------
#
# golomb.pyx:48:23: Cannot take address of cypclass
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1277, in cythonize_one
#     raise CompileError(None, pyx_file)
# Cython.Compiler.Errors.CompileError: golomb.pyx
#









#
# avec g.set_list(lst):  (une instance de cypclass en arg)

# void set_list(self, Glist glist):
#     self.glist = glist


#
# Compiling golomb.pyx because it changed.
# [1/1] Cythonizing golomb.pyx
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1256, in cythonize_one
#     result = compile_single(pyx_file, options, full_module_name=full_module_name)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Main.py", line 575, in compile_single
#     return run_pipeline(source, options, full_module_name)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Main.py", line 503, in run_pipeline
#     err, enddata = Pipeline.run_pipeline(pipeline, source)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 359, in run_pipeline
#     data = run(phase, data)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 339, in run
#     return phase(data)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 52, in generate_pyx_code_stage
#     module_node.process_implementation(options, result)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 166, in process_implementation
#     self.generate_c_code(env, options, result)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 464, in generate_c_code
#     self.generate_declarations_for_modules(env, modules, globalstate)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 694, in generate_declarations_for_modules
#     self.generate_type_definitions(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 662, in generate_type_definitions
#     self.generate_type_header_code(type_entries, code)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 909, in generate_type_header_code
#     self.generate_cpp_class_definition(entry, code)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 1527, in generate_cpp_class_definition
#     code.putln("virtual %s;" % reified.active_entry.type.declaration_code(reified.active_entry.cname))
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3486, in declaration_code
#     declarator_code = self.declarator_code(entity_code, for_display, pyrex, with_calling_convention)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3447, in declarator_code
#     arg.declaration_code(for_display, pyrex = pyrex, cname = ''))
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3820, in declaration_code
#     return self.type.declaration_code(cname, for_display, pyrex)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 4897, in declaration_code
#     return self.qual_base_type.declaration_code(entity_code, for_display, dll_linkage, pyrex, template_params, deref)
# TypeError: declaration_code() takes from 2 to 5 positional arguments but 7 were given
# jd@fuseki:~/abi/cythonplus-sandbox/exemples/golomb_cyplus_multicore$


# idem en utilisant Longlist:
#
# Compiling golomb.pyx because it changed.
# [1/1] Cythonizing golomb.pyx
# Traceback (most recent call last):
#   File "setup.py", line 26, in <module>
#     ext_modules=cythonize(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1110, in cythonize
#     cythonize_one(*args)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Build/Dependencies.py", line 1256, in cythonize_one
#     result = compile_single(pyx_file, options, full_module_name=full_module_name)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Main.py", line 575, in compile_single
#     return run_pipeline(source, options, full_module_name)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Main.py", line 503, in run_pipeline
#     err, enddata = Pipeline.run_pipeline(pipeline, source)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 359, in run_pipeline
#     data = run(phase, data)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 339, in run
#     return phase(data)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/Pipeline.py", line 52, in generate_pyx_code_stage
#     module_node.process_implementation(options, result)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 166, in process_implementation
#     self.generate_c_code(env, options, result)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 464, in generate_c_code
#     self.generate_declarations_for_modules(env, modules, globalstate)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 694, in generate_declarations_for_modules
#     self.generate_type_definitions(
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 662, in generate_type_definitions
#     self.generate_type_header_code(type_entries, code)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 909, in generate_type_header_code
#     self.generate_cpp_class_definition(entry, code)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/ModuleNode.py", line 1527, in generate_cpp_class_definition
#     code.putln("virtual %s;" % reified.active_entry.type.declaration_code(reified.active_entry.cname))
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3486, in declaration_code
#     declarator_code = self.declarator_code(entity_code, for_display, pyrex, with_calling_convention)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3447, in declarator_code
#     arg.declaration_code(for_display, pyrex = pyrex, cname = ''))
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 3820, in declaration_code
#     return self.type.declaration_code(cname, for_display, pyrex)
#   File "/usr/local/lib/python3.8/dist-packages/Cython-3.0a6-py3.8-linux-x86_64.egg/Cython/Compiler/PyrexTypes.py", line 4897, in declaration_code
#     return self.qual_base_type.declaration_code(entity_code, for_display, dll_linkage, pyrex, template_params, deref)
# TypeError: declaration_code() takes from 2 to 5 positional arguments but 7 were given
# jd@fuseki:~/abi/cythonplus-sandbox/exemples/golomb_cyplus_multicore$
