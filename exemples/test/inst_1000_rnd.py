#!/usr/bin/env python
import sys
from glob import glob
from os import makedirs
from os.path import abspath, expanduser, join, relpath, exists, splitext
from shutil import rmtree, copy2
from random import Random

SITE = abspath(expanduser("~/tmp/wntest/site1"))
STATIC_FOLDER = join(SITE, "static")


def all_images():
    images = set()
    for suffix in ("jpg",):
        # for suffix in ("gif", "jpg", "png"):
        images.update(
            [
                relpath(x, STATIC_FOLDER)
                for x in glob(join(STATIC_FOLDER, f"**/*.{suffix}"), recursive=True)
            ]
        )
    print(f"found {len(images)} files in", STATIC_FOLDER)
    return images


def main():
    avail = all_images()
    avail_lst = list(avail)
    number = 750
    if len(avail) < number:
        print("not enough images")
        sys.exit(1)
    many = join(STATIC_FOLDER, "many")
    if exists(many):
        rmtree(many)
    makedirs(many)
    r = Random()
    r.seed(1415)
    for ref in range(1, number + 1):
        img = r.choice(avail_lst)
        avail_lst.remove(img)
        ext = splitext(img)[1]
        src = join(STATIC_FOLDER, img)
        dest = join(many, f"{ref}{ext}")
        print(img, dest)
        copy2(src, dest)


def get_img_path():
    return images[r.randint(0, len(images) - 1)]
