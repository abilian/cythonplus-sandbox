# distutils: language = c++
"""
test unit AnyScalarList
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar_list cimport *
from containerlib.any_scalar_list import *

import unittest


class TestAnyScalarList(unittest.TestCase):

    data = (
        ([],                'AnyScalarList([])'),
        ([1, 2],            'AnyScalarList([(i, 1), (i, 2)])'),
        (["a", "b"],        'AnyScalarList([(s, a), (s, b)])'),
        (["a", 1, 2.5],
                'AnyScalarList([(s, a), (i, 1), (f, 2.500000)])'),
        (["a", 1, 2.5, {}, [], {"a": 1, "b": "c", "lst":[1, 2, 3]}],
                'AnyScalarList([(s, a), (i, 1), (f, 2.500000), {...}, [...], {...}])'),
    )

    def test_to_anyscalar_list_load_len(self):
        cdef AnyScalarList a

        for input, _ in self.data:
            with self.subTest(i=input):
                a = to_anyscalar_list(input)
                self.assertEqual(a.__len__(), len(input))

    def test_to_anyscalar_list(self):
        cdef AnyScalarList a

        for input, repr in self.data:
            with self.subTest(i=input):
                a = to_anyscalar_list(input)
                self.assertEqual(anyscalar_list_repr(a), repr.encode("utf8"))

    def test_from_anyscalar_list(self):
        cdef AnyScalarList a

        for input, _ in self.data:
            with self.subTest(i=input):
                a = to_anyscalar_list(input)
                retour = from_anyscalar_list(a)
                self.assertEqual(retour, input)
