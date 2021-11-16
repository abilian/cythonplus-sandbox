#!/bin/bash -v
gunicorn "t3:create_app()" -b 127.0.0.1:5000
#gunicorn --workers=2 "t3:create_app()" -b 127.0.0.1:5000
