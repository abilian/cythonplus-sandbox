# distutils: language = c++
"""
test unit AnyScalarList
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *

import unittest


data = {
    'alpha': b'bytes alpha',
    'values': [
        1, 2.0, "a string", {"c":1, "d":2, "e": {"f": {"g": 4}}}
    ],
    'beta': {
        'beta2': {
            'a': 4,
            'b': 22,
            'lst': ["A", "B", ["C", "D", ["E", "F"]]]
        },
        'beta3': 3
    },
    'gamma': 1,
    'delta': 2.5,
}


class TestAnyScalarDictMultiLevel(unittest.TestCase):

    def test_multi_level(self):
        cdef AnyScalarDict d

        d = to_anyscalar_dict(data)
        retour = from_anyscalar_dict(d)
        self.assertEqual(retour, data)
