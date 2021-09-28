# distutils: language = c++
"""
test unit AnyScalarDict and AnyScalarList for nested objects
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *

import unittest


class TestAnyScalarDictNested(unittest.TestCase):

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

    def test_nested(self):
        cdef AnyScalarDict d

        d = to_anyscalar_dict(self.data)
        retour = from_anyscalar_dict(d)
        self.assertEqual(retour,self.data)
