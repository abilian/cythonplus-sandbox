#!/usr/bin/env python
"""Some test application
"""
from config import Config
from engine import py_engine
from localtime import py_now_local


def main():
    conf = Config()
    result = py_engine(conf.content)
    print(py_now_local())
    print(result)
    print()
    print("The question in config file was:", result["response"]["the_question_was"])
    print("Response:", result["response"]["answer"])


if __name__ == "__main__":
    main()
