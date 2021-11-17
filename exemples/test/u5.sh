#!/bin/bash -v
gunicorn "t5_cy:create_app()" -b 127.0.0.1:5000
#gunicorn --workers=2 "t5_cy:create_app()" -b 127.0.0.1:5000
