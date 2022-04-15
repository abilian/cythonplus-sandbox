#!/usr/bin/env python
from glob import glob
from importlib import import_module
from os.path import splitext

import pyximport

pyximport.install(setup_args={"script_args": ["--force"]}, language_level=3)

for pyx in glob("test_*.pyx"):
    mod = import_module(splitext(pyx)[0])
    names = [x for x in mod.__dict__ if not x.startswith("_")]
    globals().update({k: getattr(mod, k) for k in names})
