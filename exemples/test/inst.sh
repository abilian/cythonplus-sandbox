#!/bin/bash
echo "Install gunicorn/whitenoise test environment"

BASE=~/tmp/wntest
[[ -d $BASE ]] || mkdir -p ${BASE}
cd ${BASE}

# gunicorn std version
#sudo port install -y py38-gunicorn
#sudo port install -y py38-setproctitle
#sudo port install -y py38-flask
sudo apt-get install -y gunicorn
sudo apt-get install -y python3-setproctitle
sudo apt-get install -y python3-flask

echo "------------------------------------"
WN=${BASE}/whitenoise
cd ${BASE}
git clone -o github https://github.com/evansd/whitenoise.git
cd ${WN}
sudo python setup.py install

echo "------------------------------------"
WRK=${BASE}/wrk
cd ${BASE}
git clone -o github https://github.com/wg/wrk.git
cd ${WRK}
make
