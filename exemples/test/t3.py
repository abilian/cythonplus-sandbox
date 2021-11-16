#!/usr/bin/env python
# gunicorn "t3:create_app()" -b 127.0.0.1:5000
# curl -I http://localhost:5000/static/australia/Image01.jpg

import os
from glob import glob
from os.path import abspath, expanduser, join, relpath
from random import Random

from flask import Flask, jsonify, send_file, send_from_directory, url_for
from whitenoise import WhiteNoise

SITE = abspath(expanduser("~/tmp/wntest/site1"))
STATIC_FOLDER = join(SITE, "static")
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
    for suffix in ("gif", "jpg", "png"):
        images.extend(
            [
                relpath(x, STATIC_FOLDER)
                for x in glob(join(STATIC_FOLDER, f"**/*.{suffix}"), recursive=True)
            ]
        )
    print(f"(found {len(images)} images)")
    return images


def create_app(script_info=None):
    app = Flask(__name__, static_folder=STATIC_FOLDER)
    WHITENOISE_MAX_AGE = 31536000

    img_list = images_list()
    rnd = Random()
    rnd.seed(1415)

    # # configure WhiteNoise
    # app.wsgi_app = WhiteNoise(
    #     app.wsgi_app,
    #     root=STATIC_FOLDER,
    #     prefix="static/",
    #     max_age=WHITENOISE_MAX_AGE,
    # )
    # print(len(app.wsgi_app.files), "files cached by Whitenoise")

    @app.route("/")
    def index():
        # img_path = "australia/Image01.jpg"
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        url = url_for("static", filename=img_path)
        return TPLATE % (url, url)

    @app.route("/random_image")
    def random_image():
        img_path = img_list[rnd.randint(0, len(img_list) - 1)]
        # return send_from_directory("groundtruth", "australia/Image01.jpg")
        return send_from_directory(STATIC_FOLDER, img_path)

    return app
