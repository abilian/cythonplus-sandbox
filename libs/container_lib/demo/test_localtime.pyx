#!/usr/bin/env python

from localtime cimport *
from localtime import *

def main():
    t = now_local()
    print(t)
    t = now_utc()
    print(t)
