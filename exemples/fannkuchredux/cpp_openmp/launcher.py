#!/usr/bin/env python

import importlib
import os
import sys
from os.path import exists, join
from time import time
from subprocess import run
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
    exe = params["exe"]
    title = params.get("title")
    function_name = params.get("function", "main")
    args = params.get("args", [])
    print(f"{title}")
    print(f"params: {args}")
    command = [exe] + [str(x) for x in args]
    t0 = time()
    run(command)
    duration = time() - t0

    print(f"duration: {duration:3.3f}s\n")


if __name__ == "__main__":
    launch()
