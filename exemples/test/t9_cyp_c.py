#!/usr/bin/env python
from cyp_c_whitenoise import WhiteNoise
from cyp_c_whitenoise import __version__ as wversion

print("found cyp_c_whitenoise version", wversion)

import wn_base_app

wn_base_app.WhiteNoise = WhiteNoise  # python closure hack !

from wn_base_app import create_app
