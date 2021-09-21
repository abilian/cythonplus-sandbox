# distutils: language = c++

from libcythonplus.dict cimport cypdict


def main():
    """
jd$ python -c "import bug_dict; bug_dict.main()"
0 0
1 10
2 20
3 30
4 40
5 50
6 60
after del d[4] :
0 0
1 10
2 20
3 30
5 50
5 50
    """
    cdef cypdict[long, long] d

    d = cypdict[long, long]()
    d[0] = 0
    d[1] = 10
    d[2] = 20
    d[3] = 30
    d[4] = 40
    d[5] = 50
    d[6] = 60
    for item in d.items():
        print(item.first, item.second)

    del d[4]

    print("after del d[4] :")
    for item in d.items():
        print(item.first, item.second)
