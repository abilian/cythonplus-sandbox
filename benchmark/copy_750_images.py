#!/usr/bin/env python
import sys
from glob import glob
from os import makedirs, rename
from os.path import abspath, expanduser, join, relpath, exists, splitext
from shutil import copy2
from random import Random

WANTED = 750


def all_images(src):
    images = set()
    for suffix in ("jpg",):
        # for suffix in ("gif", "jpg", "png"):
        images.update(
            [relpath(x, src) for x in glob(join(src, f"**/*.{suffix}"), recursive=True)]
        )
    print(f"found {len(images)} files in", src)
    return images


def main(src, dest):
    avail = all_images(src)
    avail_lst = list(avail)
    if len(avail) < WANTED:
        print(f"error, not enough images (wanted: {WANTED})")
        sys.exit(1)
    if exists(dest):
        print("===========================================================")
        print("need to remove old folder:", dest + "_old")
        print("===========================================================")
        rename(dest, dest + "_old")
    makedirs(dest)
    r = Random()
    r.seed(1415)
    for ref in range(1, WANTED + 1):
        img = r.choice(avail_lst)
        avail_lst.remove(img)
        ext = splitext(img)[1]
        src_path = join(src, img)
        dest_path = join(dest, f"{ref}{ext}")
        print(img, dest_path)
        copy2(src_path, dest_path)


if __name__ == "__main__":
    src = sys.argv[1]
    dest = sys.argv[2]
    if not exists(src):
        print("oops, no", src)
    main(src, dest)
