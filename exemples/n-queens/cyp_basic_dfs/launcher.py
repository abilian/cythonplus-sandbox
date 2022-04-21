#!/usr/bin/env python

import importlib
import os
import sys
from os.path import exists, join
from time import perf_counter

import toml

PARAMS_FILE = "params.toml"


def load_params():
    path = PARAMS_FILE
    if not exists(path):
        return {}
    # no try/except, better crash
    return toml.load(path)


def launch():
    params = load_params()
    module = params["module"]
    title = params.get("title", module)
    function_name = params.get("function", "main")
    args = params.get("args", [])
    print(f"{title}")
    print(f"params: {args}")
    function = getattr(importlib.import_module(".", module), function_name)

    t0 = perf_counter()
    function(*args)
    duration = t0 = perf_counter() - t0

    print(f"duration: {duration:3.3f}s\n")


if __name__ == "__main__":
    launch()
