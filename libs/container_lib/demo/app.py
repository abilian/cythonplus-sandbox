#!/usr/bin/env python
"""Some test application
"""
import os
import sys

from config import Config
from localtime import py_now_utc, py_now_local
from engine import py_engine


def main():
    c = Config()
    result = py_engine(c)
    print(py_now_local())
    print(result)


if __name__ == "__main__":
    main()
