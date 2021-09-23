# distutils: language = c++
"""
Cython+ experiment for containerlib classes
(using syntax of september 2021)
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from containerlib.any_scalar cimport *
from containerlib.any_scalar import *
from containerlib.any_scalar_dict cimport *
from containerlib.any_scalar_dict import *
from containerlib.scalar_dicts cimport *
from containerlib.scalar_dicts import *


def test_as_val(v):
    cdef AnyScalar a

    print("test", type(v), v, ':')
    a = python_to_any_scalar(v)
    print("repr:", a.repr())
    back = any_scalar_to_python(a)
    print("back:", type(back), back)
    print()


cdef cypclass DemoASDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using any scalars: AnyScalarDict
    """
    AnyScalarDict dic

    __init__(self, AnyScalarDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", anyscalar_dict_repr(self.dic))



def test_as():
    cdef AnyScalar a1, a2

    print('Start test AnyScalar')
    test_as_val(0)
    test_as_val(1)
    test_as_val(2**40)
    test_as_val(1.0)
    test_as_val(-5.1234)
    test_as_val("a")
    test_as_val("Zoé")
    test_as_val(b"Zoé")


def test_asd():
    cdef AnyScalarDict asd

    print('Start test AnyScalarDict')

    orig_python_dict = {
        b'alpha': b'bytes alpha',
        'beta': 'Zoé',
        'gamma': 1,
        'delta': 2.5,
    }

    asd = to_anyscalar_dict(orig_python_dict)

    # test the "from_" on initial value:
    python_dict_init = from_anyscalar_dict(asd)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoASDict(asd)
        demo.print_demo()

    # try return data (with gil)
    python_dict_asd = from_anyscalar_dict(asd)
    python_dict_result = from_anyscalar_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_asd)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)



cdef cypclass DemoStringDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: StringDict
    """
    StringDict dic

    __init__(self, StringDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", string_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] = string("new alpha")  # and hope we catch the b'alpha'
        # warn: here we need a cast:
        self.dic['beta'] = sprintf("%s%s", <string> self.dic['beta'], string(" more beta"))
        self.dic['gamma'] = string("three")  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 'other value'
        d = StringDict()
        d['update'] = "updated"  # here cast not needed
        self.dic.update(d)
        printf("modified content: %s\n", string_dict_repr(self.dic))



def test_string_dict():
    cdef StringDict sdic

    print('Start test StringDict')

    orig_python_string_dict = {
        b'alpha': b'bytes alpha',
        'beta': 'Zoé',
        'gamma': 'trois',
        'delta': 'quatre',
        'epsilon': ''
    }

    sdic = to_string_dict(orig_python_string_dict)

    # test the from_ on initial value:
    python_dict_init = from_string_dict(sdic)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoStringDict(sdic)
        demo.print_demo()

    # try return data (with gil)
    python_dict_sdic = from_string_dict(sdic)
    python_dict_result = from_string_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_sdic)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # Note: result is ok with del_item fix of 21sept


cdef cypclass DemoNumDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: NumDict
    """
    NumDict dic

    __init__(self, NumDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic
        # warn: we work inplace on the input parameter

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())  # but this is ok !
        printf("dict content: %s\n", num_dict_repr(self.dic))   # using hand made repr()

        #### make some operations
        self.dic[1] += 111  # here cast not needed
        self.dic[2] = self.dic[2] + 2000  # here cast not needed
        self.dic[3] = 5000  # here cast not needed
        del self.dic[4]
        self.dic[10] = 1010

        d = NumDict()
        d[55] = 555
        self.dic.update(d)

        printf("modified content: %s\n", num_dict_repr(self.dic))



def test_num_dict():
    cdef NumDict nd

    print('Start test NumDict')

    orig_python_num_dict = {0:0, 1:1, 2:1, 3:2, 4:3, 5:5, 6:8}

    nd = to_num_dict(orig_python_num_dict)
    # test the from_num_dict on initial value:
    python_dict_init = from_num_dict(nd)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoNumDict(nd)
        demo.print_demo()

    # try return data (with gil)
    python_dict_nd = from_num_dict(nd)
    python_dict_result = from_num_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_nd)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # Note: result is ok with del_item fix of 21sept



cdef cypclass DemoLongDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: LongDict
    """
    LongDict dic

    __init__(self, LongDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", long_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] += 111  # here cast not needed
        # and hope we catch the b'alpha'
        self.dic['beta'] = self.dic['beta'] + 2000  # here cast not ne
        self.dic['gamma'] = 5000  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 1010

        d = LongDict()
        d['update'] = 555
        self.dic.update(d)

        printf("modified content: %s\n", long_dict_repr(self.dic))



def test_long_dict():
    cdef LongDict ldic

    print('Start test LongDict')

    orig_python_long_dict = {
        b'alpha': 1,
        'beta': 2,
        'gamma': 3,
        'delta': 4,
        'epsilon': 5}

    ldic = to_long_dict(orig_python_long_dict)
    # test the from_ on initial value:
    python_dict_init = from_long_dict(ldic)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoLongDict(ldic)
        demo.print_demo()

    # try return data (with gil)
    python_dict_ldic = from_long_dict(ldic)
    python_dict_result = from_long_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_ldic)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # note: result is ok with del_item fix of 21sept


cdef cypclass DemoFloatDict:
    """A demo cypclass, to experiment how to stay as long as possible in the nogil
    perimeter

    - demo of a cypdict using scalars: FloatDict
    """
    FloatDict dic

    __init__(self, FloatDict param_dic):  # remember: no default parameter allowed
        self.dic = param_dic

    void print_demo(self):
        """method executed with nogil status
        """
        printf("dic.__len__:  %d\n", self.dic.__len__())
        printf("dict content: %s\n", float_dict_repr(self.dic))  # using hand made repr()

        #### make some operations
        self.dic['alpha'] += 1.23456  # here cast not needed
        # and hope we catch the b'alpha'
        self.dic['beta'] = self.dic['beta'] - 1000   # here cast not ne
        self.dic['gamma'] = 5e20  # here cast not needed
        del self.dic['delta']
        self.dic['other'] = 3.1415926536

        d = FloatDict()
        d['update'] = 42
        self.dic.update(d)

        printf("modified content: %s\n", float_dict_repr(self.dic))



def test_float_dict():
    cdef FloatDict fd

    print('Start test FloatDict')

    orig_python_float_dict = {
        b'alpha': 0.0,
        'beta': 2.0,
        'gamma': 3.333333333333,
        'delta': 4,
        'epsilon': 5}

    fd = to_float_dict(orig_python_float_dict)
    python_dict_init = from_float_dict(fd)

    with nogil:  # starting in nogil to see if how to pass arguments
        demo = DemoFloatDict(fd)
        demo.print_demo()

    # try return data (with gil)
    python_dict_fd = from_float_dict(fd)
    python_dict_result = from_float_dict(demo.dic)
    print('in "python/gil" perimeter:')
    print("  - initial dict:", python_dict_init)
    print("  - parameter dict:", python_dict_fd)
    print("(So the parameter dict was modified in place)")
    print("  - modified dict:", python_dict_result)
    # note: result is ok with del_item fix of 21sept


def test_super_dict():
    cdef NumDict test_dic1
    cdef LongDict test_dic2
    cdef FloatDict test_dic3
    cdef SuperDict sdic1, sdic2

    print('Start test SuperDict')

    orig_num_dict = {0: 0, 1: 1, 2: 1, 3: 2, 4: 3, 5: 5, 6: 8}
    orig_long_dict = {'zero': 0, b'un': 1, 'deux': 2, 'trois': 3, 'quatre': 4}
    orig_float_dict = {'zero': 0.0, b'un': 1.0, 'deux': 2.2, 'trois': 3.3, 'quatre': 4.4}
    orig_string_dict = {"a": "A", "b": "B", "c": "C", "d": "D"}

    test_dic1 = to_num_dict(orig_num_dict)
    sdic1 = new_super_dict(test_dic1)
    printf("test num, super dict type: %s \n", sdic1.type)
    printf("%s \n", sdic1.repr())
    print(super_dict_to_python_dict(sdic1))

    print()
    test_dic2 = to_long_dict(orig_long_dict)
    sdic2 = new_super_dict(test_dic2)
    printf("test long, super dict type: %s \n", sdic2.type)
    printf("%s \n", sdic2.repr())
    print(super_dict_to_python_dict(sdic2))

    print()
    test_dic3 = to_float_dict(orig_float_dict)
    sdic2 = new_super_dict(test_dic3)
    printf("test float, super dict type: %s \n", sdic2.type)
    printf("%s \n", sdic2.repr())
    print(super_dict_to_python_dict(sdic2))

    print()
    sdic2 = python_dict_to_super_dict(orig_num_dict)
    printf("test2a, super dict type: %s \n", sdic2.type)
    printf("test2a, super dict repr(): \n    %s\n", sdic2.repr())
    print(super_dict_to_python_dict(sdic2))

    print()
    print("Same super dict instance will now store another type of dict:")
    sdic2 = python_dict_to_super_dict(orig_string_dict)
    printf("test2b, super dict type: %s \n", sdic2.type)
    printf("test2b, super dict repr(): \n    %s\n", sdic2.repr())
    print(super_dict_to_python_dict(sdic2))


def main():
    print("\n" + "-" * 30)
    test_as()
    print("\n" + "-" * 30)
    test_asd()
    print("\n" + "-" * 30)
    test_string_dict()
    print("\n" + "-" * 30)
    test_num_dict()
    print("\n" + "-" * 30)
    test_long_dict()
    print("\n" + "-" * 30)
    test_float_dict()
    print("\n" + "-" * 30)
    test_super_dict()
    print("\n" + "-" * 30)
    print("The end.")
