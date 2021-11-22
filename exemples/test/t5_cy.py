#!/usr/bin/env python
from cywhitenoise import WhiteNoise
from cywhitenoise import __version__ as wversion

print("found cywhitenoise version", wversion)

import wn_base_app

wn_base_app.WhiteNoise = WhiteNoise  # python closure hack !

from wn_base_app import create_app