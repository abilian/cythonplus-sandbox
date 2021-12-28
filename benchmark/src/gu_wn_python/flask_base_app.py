#!/usr/bin/env python
"""Minimal falsk app serving some static files

test with curl: curl -I http://localhost:5000/static/australia/Image01.jpg
"""
import os
from glob import glob
from os.path import abspath, expanduser, join, relpath
from random import Random
from time import perf_counter
from os import environ

from flask import Flask, jsonify, send_file, send_from_directory, url_for


TPLATE = """<!DOCTYPE html>
<head>
  <meta charset="UTF-8">
  <title>Test random image</title>
</head>
<body>
  <h2> %s </h2>
  <div>
    <img alt="" src="%s">
  </div>
</body>
</html>
"""


def images_list(static_folder):
    images = []
    for suffix in ("jpg",):
        images.extend(
            [
                relpath(x, static_folder)
                for x in glob(join(static_folder, f"**/*.{suffix}"), recursive=True)
            ]
        )
    print(f"found {len(images)} files in", static_folder)
    return images


def create_app(script_info=None):
    static_folder = environ.get("STATIC_FOLDER")
    root_path = environ.get("ROOT_PATH")
    static_path = join(root_path, static_folder)
    app = Flask(__name__, root_path=root_path, static_folder=static_folder)

    app.config["APPLICATION_ROOT"] = environ.get("APPLICATION_ROOT")
    app.config["SERVER_NAME"] = environ.get("SERVER_NAME")
    WHITENOISE_MAX_AGE = 31536000
    app.debug = True

    img_list = images_list(static_path)
    rnd = Random()
    rnd.seed(1415)

    t0 = perf_counter()
    # configure WhiteNoise
    app.wsgi_app = WhiteNoise(
        app.wsgi_app,
        root=static_path,
        prefix="static/",
        max_age=WHITENOISE_MAX_AGE,
    )
    try:
        print(app.wsgi_app.nb_cached_files(), "files cached by Whitenoise")
    except AttributeError:
        print(len(app.wsgi_app.files), "files cached by Whitenoise")
    print("Whitenoise initialization (ms):", (perf_counter() - t0) * 1000)
    print()

    @app.route("/")
    def index():
        # img_path = "australia/Image01.jpg"
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        url = url_for("static", filename=img_path)
        return TPLATE % (url, url)

    @app.route("/random_image")
    def random_image():
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        url = url_for("static", filename=img_path)
        return TPLATE % (url, url)

    return app
