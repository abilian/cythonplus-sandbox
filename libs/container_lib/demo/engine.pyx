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
    string ask
    AnyScalarList test

    __init__(self, AnyScalarDict config):
        self.config = config
        self.result = AnyScalarDict()
        self.computation = LongDict()

    AnyScalarDict run(self):
        cdef AnyScalarDict d

        self.parse_config()
        self.compute()
        self.result["config"] = new_any_scalar(self.config)
        # warning: here conversion from LongDict to AnyScalarDict
        d = convert_to_asd(self.computation)
        d["the_question_was"] = new_any_scalar(self.ask)
        self.result["response"] = new_any_scalar(d)
        return self.result

    void parse_config(self):
        # looking for the "engine" key
        cdef string kw
        cdef AnyScalarDict eng

        kw = string("engine")
        eng = (<AnyScalar> self.config[kw]).a_dict
        self.ask = (<AnyScalar> eng["the_question_is"]).a_string
        self.test = (<AnyScalar> eng["test"]).a_list

    AnyScalarDict compute(self):
        """Main computation is here.
        """
        self.computation["answer"] = 42



cdef AnyScalarDict convert_to_asd(LongDict d) nogil:
    """convert LongDict (a cypdict[string, long]) to AnyScalarDict
       (a cypdict[string, AnyScalar]
    """
    cdef AnyScalarDict asd

    asd = AnyScalarDict()
    for item in d.items():
        asd[item.first] = new_any_scalar(item.second)
    return asd


cpdef py_engine(config):
    """Interface from python world and cythony+ world, convert arguments.

    - config argument is a python dict
    - conversion to the AnyScalarDict format (a cypclass)
    - and conversion from the AnyScalarDict format back to python dict
    """
    cdef AnyScalarDict config_asd
    cdef AnyScalarDict result_asd
    cdef Engine engine

    config_asd = to_anyscalar_dict(config)
    engine = Engine(config_asd)
    result_asd = engine.run()
    result = from_anyscalar_dict(result_asd)

    return result
