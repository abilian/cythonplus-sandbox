# distutils: language = c++
from stdlib.string cimport Str
from abspath cimport abspath

def main():
    for s in "./toto nonexist . .. /etc ./test_abspath.pyx".split():
        print(s, '->', abspath(Str(s.encode("utf8"))).bytes())
