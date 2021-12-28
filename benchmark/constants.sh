#!/bin/bash
# constants for benchmark installation

# Warning: when changing values, need to adapt wrk_rnd.lua

# where is the website with static files:
ROOT=~/tmp/site_root
STATIC_FOLDER=static
IMAGES=${ROOT}/${STATIC_FOLDER}/images

# where are stored tar files of images
IMGSRC=~/tmp/images_src

# the temporary git folder for whitenois and wrk
TMPGIT=~/tmp/git_tmp

# the wrk executable
WRK=${TMPGIT}/wrk/wrk
