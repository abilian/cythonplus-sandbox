# distutils: language = c++
"""
Test unit for module scalar_dicts.pyx
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.scalar_dicts cimport *
from containerlib.scalar_dicts import *

import unittest


class TestStringDict(unittest.TestCase):

    data = {
        "alpha": b"bytes alpha",
        "beta": "Zoé",
        "gamma": "trois",
        "delta": "quatre",
        "epsilon": ""
    }
    data_str = {
        "alpha": "bytes alpha",
        "beta": "Zoé",
        "gamma": "trois",
        "delta": "quatre",
        "epsilon": ""
    }
    repr = (
        "StringDict({"
        "alpha:bytes alpha, "
        "beta:Zoé, "
        "gamma:trois, "
        "delta:quatre, "
        "...})"
        ).encode("utf8")

    def test_python_py_to_string_dict_len(self):
        cdef StringDict d

        d = py_to_string_dict(self.data)
        self.assertEqual(d.__len__(), len(self.data))

    def test_python_py_to_string_dict_len_0(self):
        cdef StringDict d

        d = py_to_string_dict({})
        self.assertEqual(d.__len__(), 0)

    def test_string_dict_repr(self):
        cdef StringDict d

        d = py_to_string_dict(self.data)
        self.assertEqual(string_dict_repr(d), self.repr)

    def test_string_dict_repr_empty(self):
        cdef StringDict d

        d = py_to_string_dict({})
        self.assertEqual(string_dict_repr(d), b"StringDict({})")

    def test_string_dict_to_py(self):
        cdef StringDict d

        d = py_to_string_dict(self.data)
        retour = string_dict_to_py(d)
        self.assertEqual(retour, self.data_str)

    def test_string_dict_to_py_empty(self):
        cdef StringDict d

        d = py_to_string_dict({})
        retour = string_dict_to_py(d)
        self.assertEqual(retour, {})



class TestNumDict(unittest.TestCase):

    data = {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 5, 6: 8}
    repr = (
        "NumDict("
        "{0:0, 1:1, 2:1, 3:2, 4:3, 5:5, 6:8}"
        ")"
        ).encode("utf8")

    def test_python_py_to_num_dict_len(self):
        cdef NumDict d

        d = py_to_num_dict(self.data)
        self.assertEqual(d.__len__(), len(self.data))

    def test_python_py_to_num_dict_len_0(self):
        cdef NumDict d

        d = py_to_num_dict({})
        self.assertEqual(d.__len__(), 0)

    def test_num_dict_repr(self):
        cdef NumDict d

        d = py_to_num_dict(self.data)
        self.assertEqual(num_dict_repr(d), self.repr)

    def test_num_dict_repr_empty(self):
        cdef NumDict d

        d = py_to_num_dict({})
        self.assertEqual(num_dict_repr(d), b"NumDict({})")

    def test_num_dict_to_py(self):
        cdef NumDict d

        d = py_to_num_dict(self.data)
        retour = num_dict_to_py(d)
        self.assertEqual(retour, self.data)

    def test_num_dict_to_py_empty(self):
        cdef NumDict d

        d = py_to_num_dict({})
        retour = num_dict_to_py(d)
        self.assertEqual(retour, {})



class TestLongDict(unittest.TestCase):

    data = {
        b"alpha": 1,
        "beta": 2,
        "gamma": 3,
        "delta": 4,
        "epsilon": 2**50
    }
    data_str = {
        "alpha": 1,
        "beta": 2,
        "gamma": 3,
        "delta": 4,
        "epsilon": 2**50
    }
    repr = (
        "LongDict("
        "{alpha:1, beta:2, gamma:3, delta:4, epsilon:1125899906842624}"
        ")"
        ).encode("utf8")

    def test_python_py_to_long_dict_len(self):
        cdef LongDict d

        d = py_to_long_dict(self.data)
        self.assertEqual(d.__len__(), len(self.data))

    def test_python_py_to_long_dict_len_0(self):
        cdef LongDict d

        d = py_to_long_dict({})
        self.assertEqual(d.__len__(), 0)

    def test_long_dict_repr(self):
        cdef LongDict d

        d = py_to_long_dict(self.data)
        self.assertEqual(long_dict_repr(d), self.repr)

    def test_long_dict_repr_empty(self):
        cdef LongDict d

        d = py_to_long_dict({})
        self.assertEqual(long_dict_repr(d), b"LongDict({})")

    def test_long_dict_to_py(self):
        cdef LongDict d

        d = py_to_long_dict(self.data)
        retour = long_dict_to_py(d)
        self.assertEqual(retour, self.data_str)

    def test_long_dict_to_py_empty(self):
        cdef LongDict d

        d = py_to_long_dict({})
        retour = long_dict_to_py(d)
        self.assertEqual(retour, {})



class TestFloatDict(unittest.TestCase):

    data = {
        b"alpha": 0,
        "beta": 2,
        "gamma": 3.5,
        "delta": 4.333333,
        "epsilon": -3.14
    }
    data_str = {
        "alpha": 0,
        "beta": 2,
        "gamma": 3.5,
        "delta": 4.333333,
        "epsilon": -3.14
    }
    repr = (
        "FloatDict("
        "{alpha:0.000000, "
        "beta:2.000000, "
        "gamma:3.500000, "
        "delta:4.333333, "
        "...}"
        ")"
        ).encode("utf8")

    def test_python_py_to_float_dict_len(self):
        cdef FloatDict d

        d = py_to_float_dict(self.data)
        self.assertEqual(d.__len__(), len(self.data))

    def test_python_py_to_float_dict_len_0(self):
        cdef FloatDict d

        d = py_to_float_dict({})
        self.assertEqual(d.__len__(), 0)

    def test_float_dict_repr(self):
        cdef FloatDict d

        d = py_to_float_dict(self.data)
        self.assertEqual(float_dict_repr(d), self.repr)

    def test_float_dict_repr_empty(self):
        cdef FloatDict d

        d = py_to_float_dict({})
        self.assertEqual(float_dict_repr(d), b"FloatDict({})")

    def test_float_dict_to_py(self):
        cdef FloatDict d

        d = py_to_float_dict(self.data)
        retour = float_dict_to_py(d)
        self.assertEqual(retour, self.data_str)

    def test_float_dict_to_py_empty(self):
        cdef FloatDict d

        d = py_to_float_dict({})
        retour = float_dict_to_py(d)
        self.assertEqual(retour, {})



class TestSuperDict(unittest.TestCase):

    d_num = {1: 2}
    d_long = {"one": 2}
    d_str = {"one": "two"}
    d_float = {"one": 1.0}
    d_bad = {"some": 1, "bad": "value"}
    d_num_repr = b"NumDict({1:2})"
    d_long_repr = b"LongDict({one:2})"
    d_str_repr = b"StringDict({one:two})"
    d_float_repr = b"FloatDict({one:1.000000})"

    def test_py_to_superdict_num(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_num)
        self.assertEqual(d.type, b"NumDict")

    def test_py_to_superdict_long(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_long)
        self.assertEqual(d.type, b"LongDict")

    def test_py_to_superdict_string(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_str)
        self.assertEqual(d.type, b"StringDict")

    def test_py_to_superdict_float(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_float)
        self.assertEqual(d.type, b"FloatDict")

    def test_python_to_super_dict_len_0(self):
        cdef SuperDict d

        d = py_to_superdict({})
        self.assertEqual(d.type, b"StringDict")

    # def test_python_to_super_dict_bad(self):
    #     cdef SuperDict d
    #
    #     # need to wrap with superdict_to_py() to have python object
    #     self.assertRaises(ValueError,
    #                       superdict_to_py(
    #                             py_to_superdict(self.d_bad)
    #                       )
    #     )

    def test_super_dict_clean(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_str)
        self.assertEqual(d.type, b"StringDict")
        d.clean()
        self.assertEqual(d.type, b"")

    def test_super_dict_load_another_dict_variant(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_str)
        self.assertEqual(d.type, b"StringDict")
        d = py_to_superdict(self.d_long)
        self.assertEqual(d.type, b"LongDict")

    def test_super_dict_num_repr(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_num)
        self.assertEqual(d.repr(), self.d_num_repr)

    def test_super_dict_string_repr(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_str)
        self.assertEqual(d.repr(), self.d_str_repr)

    def test_super_dict_long_repr(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_long)
        self.assertEqual(d.repr(), self.d_long_repr)

    def test_super_dict_float_repr(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_float)
        self.assertEqual(d.repr(), self.d_float_repr)

    def test_super_dict_to_python_num(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_num)
        retour = superdict_to_py(d)
        self.assertEqual(retour, self.d_num)

    def test_super_dict_to_python_string(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_str)
        retour = superdict_to_py(d)
        self.assertEqual(retour, self.d_str)

    def test_super_dict_to_python_long(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_long)
        retour = superdict_to_py(d)
        self.assertEqual(retour, self.d_long)

    def test_super_dict_to_python_float(self):
        cdef SuperDict d

        d = py_to_superdict(self.d_float)
        retour = superdict_to_py(d)
        self.assertEqual(retour, self.d_float)
