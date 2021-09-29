# distutils: language = c++
"""
test unit for new_any_scalar()
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar cimport *
from containerlib.any_scalar import *
from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *
from containerlib.any_scalar_list cimport *
from containerlib.any_scalar_list import *

import unittest


class TestAnyscalarNew(unittest.TestCase):

    data_str = ("a string", b"AnyScalar(s, a string)")
    data_long = (42, b"AnyScalar(i, 42)")
    data_double = (3.14, b"AnyScalar(f, 3.140000)")
    data_dict = ({"a": "value"}, b"AnyScalarDict(...)")
    data_list = ([1, 2, "c"], b"AnyScalarList(...)")
    data_any = ({"a": "value"}, b"AnyScalarDict(...)")
    data_any2 = (1515, b"AnyScalar(i, 1515)")
    data_any3 = ("some str", b"AnyScalar(s, some str)")

    def test_new_any_scalar_string(self):
        cdef AnyScalar a
        cdef string s

        s = string(bytes(self.data_str[0].encode("utf8")))
        a = new_any_scalar(s)
        self.assertEqual(a.repr(), self.data_str[1])

    def test_new_any_scalar_long(self):
        cdef AnyScalar a
        cdef long i

        i = self.data_long[0]
        a = new_any_scalar(i)
        self.assertEqual(a.repr(), self.data_long[1])

    def test_new_any_scalar_double(self):
        cdef AnyScalar a
        cdef double f

        f = self.data_double[0]
        a = new_any_scalar(f)
        self.assertEqual(a.repr(), self.data_double[1])

    def test_new_any_scalar_dict(self):
        cdef AnyScalar a
        cdef AnyScalarDict d

        d = to_anyscalar_dict(self.data_dict[0])
        a = new_any_scalar(d)
        self.assertEqual(a.repr(), self.data_dict[1])

    def test_new_any_scalar_list(self):
        cdef AnyScalar a
        cdef AnyScalarList lst

        lst = to_anyscalar_list(self.data_list[0])
        a = new_any_scalar(lst)
        self.assertEqual(a.repr(), self.data_list[1])

    def test_new_any_scalar_any_scalar(self):
        cdef AnyScalar a, b

        b = python_to_any_scalar(self.data_any[0])
        a = new_any_scalar(b)
        self.assertEqual(a.repr(), self.data_any[1])

    def test_new_any_scalar_any_scalar2(self):
        cdef AnyScalar a, b

        b = python_to_any_scalar(self.data_any2[0])
        a = new_any_scalar(b)
        self.assertEqual(a.repr(), self.data_any2[1])

    def test_new_any_scalar_any_scalar3(self):
        cdef AnyScalar a, b

        b = python_to_any_scalar(self.data_any3[0])
        a = new_any_scalar(b)
        self.assertEqual(a.repr(), self.data_any3[1])
