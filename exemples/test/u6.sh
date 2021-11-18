#!/bin/bash -v
gunicorn "t6_cyp_min:create_app()" -b 127.0.0.1:5000
#gunicorn --workers=2 "t5_cy:create_app()" -b 127.0.0.1:5000
