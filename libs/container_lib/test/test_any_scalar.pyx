# distutils: language = c++
"""
test unit AnyScalar
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar cimport *
from containerlib.any_scalar import *

import unittest


class TestAnyscalar(unittest.TestCase):

    data = (
        (0,         "i", "AnyScalar(i, 0)",             "(i, 0)"),
        (1,         "i", "AnyScalar(i, 1)",             "(i, 1)"),
        (2**40,     "i", "AnyScalar(i, 1099511627776)", "(i, 1099511627776)"),
        (1.0,       "f", "AnyScalar(f, 1.000000)",      "(f, 1.000000)"),
        (-1.234,    "f", "AnyScalar(f, -1.234000)",     "(f, -1.234000)"),
        ('a',       "s", "AnyScalar(s, a)",             "(s, a)"),
        ("Zoé" ,    "s", "AnyScalar(s, Zoé)",           "(s, Zoé)"),
        ("Zoé".encode("utf8"),
                    "b", "AnyScalar(b, Zoé)",           "(b, Zoé)"),
        ({},        "d", "AnyScalarDict(...)",          "{...}"),
        ({"a": 1},  "d", "AnyScalarDict(...)",          "{...}"),
        ([],        "l", "AnyScalarList(...)",          "[...]"),
        ([1, 2, 3], "l", "AnyScalarList(...)",          "[...]"),
    )

    def test_python_to_any_scalar_type(self):
        cdef AnyScalar a

        for input, tpe, _, _  in self.data:
            with self.subTest(i=input):
                a = python_to_any_scalar(input)
                self.assertEqual(chr(a.type), tpe)

    def test_any_scalar_repr(self):
        cdef AnyScalar a

        for input, _, repr, _  in self.data:
            with self.subTest(i=input):
                a = python_to_any_scalar(input)
                self.assertEqual(a.repr().decode("utf8", "replace"), repr)

    def test_any_scalar_short_r(self):
        cdef AnyScalar a

        for input, _, _, short_r in self.data:
            with self.subTest(i=input):
                a = python_to_any_scalar(input)
                self.assertEqual(a.short_repr().decode("utf8", "replace"), short_r)

    def test_any_scalar_to_python(self):
        cdef AnyScalar a

        for input, _, _, _ in self.data:
            with self.subTest(i=input):
                a = python_to_any_scalar(input)
                retour = any_scalar_to_python(a)
                self.assertEqual(retour, input)

    def test_any_scalar_clean(self):
        cdef AnyScalar a
        a = python_to_any_scalar(1)
        a.clean()
        self.assertEqual(chr(a.type), " ")
        self.assertEqual(a.a_long, 0)
