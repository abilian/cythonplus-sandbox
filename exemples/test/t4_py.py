#!/usr/bin/env python
from whitenoise import WhiteNoise
from whitenoise import __version__ as wversion

print("found whitenoise version", wversion)

import wn_base_app

wn_base_app.WhiteNoise = WhiteNoise  # python closure hack !

from wn_base_app import create_app
