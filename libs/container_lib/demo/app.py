#!/usr/bin/env python
"""Some test application
"""
import os
import sys

from config import Config
from localtime import py_now_utc, py_now_local
from engine import py_engine


def main():
    conf = Config()
    result = py_engine(conf.content)
    print(py_now_local())
    print(result)
    print("Answer:")
    print(result["result"]["answer"])


if __name__ == "__main__":
    main()
