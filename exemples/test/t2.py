#!/usr/bin/env python
# gunicorn "t1:create_app()" -b 127.0.0.1:5000
# curl -I http://localhost:5000/australia/Image01.jpg

import os
from glob import glob
from os.path import abspath, expanduser, join, relpath
from random import Random

from flask import Flask, jsonify, send_file, send_from_directory
from whitenoise import WhiteNoise

TEST_ROOT = abspath(expanduser("~/tmp/wntest"))
TEST_STATIC = "groundtruth"
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


def images_list():
    images = []
    path = TEST_ROOT
    for suffix in ("gif", "jpg", "png"):
        images.extend(
            [
                relpath(x, path)
                for x in glob(join(path, f"groundtruth/**/*.{suffix}"), recursive=True)
            ]
        )
    print(images)
    return images


def create_app(script_info=None):

    app = Flask("test1", static_folder=TEST_STATIC)

    WHITENOISE_MAX_AGE = 31536000

    img_list = images_list()
    rnd = Random()
    rnd.seed(1415)

    # # configure WhiteNoise
    # app.wsgi_app = WhiteNoise(
    #     app.wsgi_app,
    #     root=join(TEST_ROOT, TEST_STATIC),
    #     prefix="/groundtruth",
    #     max_age=WHITENOISE_MAX_AGE,
    # )

    @app.route("/index.html")
    def index():
        # img_path = "/groundtruth/australia/Image01.jpg"
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        return TPLATE % (img_path, img_path)

    # @app.route("/random_image")
    # def random_image():
    #     img_path = img_list[rnd.randint(0, len(img_list) - 1)]
    #     # return send_from_directory("/groundtruth", img_path)
    #     return send_from_directory("/groundtruth/australia", "Image01.jpg")

    @app.route("/groundtruth/any")
    def random_image():
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        # return send_from_directory("groundtruth", "australia/Image01.jpg")
        return send_file("/groundtruth/australia/Image01.jpg")

    return app
