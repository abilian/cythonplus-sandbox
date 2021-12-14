#!/usr/bin/env python
import fastwsgi

from cyp_g_whitenoise import WhiteNoise
from cyp_g_whitenoise import __version__ as wversion

print("found cyp_g_whitenoise version", wversion)

import wn_base_app

wn_base_app.WhiteNoise = WhiteNoise  # python closure hack !

from wn_base_app import create_app

app = create_app()
if __name__ == "__main__":
    fastwsgi.run(wsgi_app=app, host="127.0.0.1", port=5000)
