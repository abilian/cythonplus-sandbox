#!/usr/bin/env python
"""instance of whitenoise for minimal gunicorn/flask app
"""
from whitenoise import WhiteNoise
from whitenoise import __version__ as v

print("using whitenoise version", v)

import flask_base_app

flask_base_app.WhiteNoise = WhiteNoise

from flask_base_app import create_app
