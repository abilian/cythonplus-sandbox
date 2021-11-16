#!/usr/bin/env python

from glob import glob
from os.path import abspath, expanduser, join, relpath
from random import Random

path = abspath(expanduser("~/tmp/wntest"))

images = []
for suffix in ("gif", "jpg", "png"):
    images.extend(
        [
            relpath(x, path)
            for x in glob(join(path, f"groundtruth/**/*.{suffix}"), recursive=True)
        ]
    )
# print(images)

r = Random()
r.seed(1415)


def get_img_path():
    return images[r.randint(0, len(images) - 1)]


for i in range(10):
    print(get_img_path())
