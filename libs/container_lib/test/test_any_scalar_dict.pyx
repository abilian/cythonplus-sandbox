# distutils: language = c++
"""
test unit AnyScalarDict
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *

import unittest


class TestAnyScalarDict(unittest.TestCase):

    data = {
        "alpha": b"value is bytes",
        "beta": "Zoé",
        "gamma": 1,
        "delta": 2.5,
    }
    repr = (
        "AnyScalarDict({alpha:(b, value is bytes), "
        "beta:(s, Zoé), "
        "gamma:(i, 1), "
        "...})"
        ).encode("utf8")

    def test_to_anyscalar_dict_load_len(self):
        cdef AnyScalarDict asd

        asd = to_anyscalar_dict(self.data)
        self.assertEqual(asd.__len__(), 4)

    def test_to_anyscalar_dict(self):
        cdef AnyScalarDict asd

        asd = to_anyscalar_dict(self.data)
        self.assertEqual(anyscalar_dict_repr(asd), self.repr)

    def test_from_anyscalar_dict(self):
        cdef AnyScalarDict asd

        asd = to_anyscalar_dict(self.data)
        retour = from_anyscalar_dict(asd)
        self.assertEqual(retour, self.data)
