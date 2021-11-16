#!/usr/bin/env python
# gunicorn "t1:create_app()" -b 127.0.0.1:5000
# curl -I http://localhost:5000/australia/Image01.jpg

import os
from os.path import abspath, expanduser, join, relpath

from flask import Flask, jsonify
from whitenoise import WhiteNoise

TEST_ROOT = abspath(expanduser("~/tmp/wntest"))
TEST_STATIC = "groundtruth"


def create_app(script_info=None):

    app = Flask("test1", static_folder=TEST_STATIC)

    WHITENOISE_MAX_AGE = 31536000

    # configure WhiteNoise
    app.wsgi_app = WhiteNoise(
        app.wsgi_app,
        root=join(TEST_ROOT, TEST_STATIC),
        prefix="/",
        max_age=WHITENOISE_MAX_AGE,
    )

    @app.route("/")
    def hello_world():
        return jsonify(hello="world")

    return app
