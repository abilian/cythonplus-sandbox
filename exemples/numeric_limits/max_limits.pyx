# distutils: language = c++
"""
Show compiler max limits
"""
from stdlib.string cimport string
from stdlib.fmt cimport printf, sprintf

from libcpp.limits cimport numeric_limits


def main():
    print("      bint :", numeric_limits[bint].max())
    print("      char :", numeric_limits[char].max())
    print("     uchar :", numeric_limits[uchar].max())
    print("     short :", numeric_limits[short].max())
    print("       int :", numeric_limits[int].max())
    print("      long :", numeric_limits[long].max())
    print("     ulong :", numeric_limits[ulong].max())
    print("  longlong :", numeric_limits[longlong].max())
    print(" ulonglong :", numeric_limits[ulonglong].max())
    print("     float :", numeric_limits[float].max())
    print("    double :", numeric_limits[double].max())
    print("longdouble :", numeric_limits[longdouble].max())
