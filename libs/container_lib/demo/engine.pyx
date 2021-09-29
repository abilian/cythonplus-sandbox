# distutils: language = c++
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf
from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *
from containerlib.any_scalar_list cimport *
from containerlib.any_scalar_list import *
from containerlib.any_scalar cimport *
from containerlib.any_scalar import *
from containerlib.scalar_dicts cimport *
from containerlib.scalar_dicts import *



cdef cypclass Engine:
    AnyScalarDict config
    LongDict computation
    AnyScalarDict result
    string motor
    AnyScalarList args
    AnyScalarList expected

    __init__(self, AnyScalarDict config):
        self.config = config
        self.result = AnyScalarDict()
        self.computation = LongDict()

    AnyScalarDict run(self):
        self.parse_config()
        self.compute()
        self.result["config"] = new_any_scalar(self.config)
        # hack:
        self.result["result"] = new_any_scalar(convert_to_asd(self.computation))
        return self.result

    void parse_config(self):
        # looking for the "engine" key
        cdef string kw
        cdef AnyScalarDict eng

        kw = string("engine")
        eng = (<AnyScalar> self.config[kw]).a_dict
        self.motor = (<AnyScalar> eng["motor"]).a_string
        # with gil:
        self.args = (<AnyScalar> eng["args"]).a_list
        self.expected = (<AnyScalar> eng["return"]).a_list

    AnyScalarDict compute(self):
        """Main computation is here.
        """
        self.computation["answer"] = 42


#hack:
cdef AnyScalarDict convert_to_asd(LongDict d) nogil:
    cdef AnyScalarDict asd

    asd = AnyScalarDict()
    for item in d.items():
        asd[item.first] = new_any_scalar(item.second)
    return asd


cpdef py_engine(config):
    """Interface from Py world and Cy+ world, convert arguments.
    """
    cdef AnyScalarDict config_asd
    cdef AnyScalarDict result_asd
    cdef Engine engine

    config_asd = to_anyscalar_dict(config)
    engine = Engine(config_asd)
    result_asd = engine.run()
    result = from_anyscalar_dict(result_asd)

    return result
