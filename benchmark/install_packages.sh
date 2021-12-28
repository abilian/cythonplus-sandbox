#!/bin/bash
echo "Install gunicorn, flask, whitenoise, wrk for the tests"

# script to be run from this folder:
[[ -f install_packages.sh ]] || exit 1

. constants.sh
ORIG="$PWD"
[[ -d $TMPGIT ]] || mkdir -p ${TMPGIT}
cd ${TMPGIT}

# install gunicorn std version
#sudo port install -y py38-gunicorn
#sudo port install -y py38-setproctitle
#sudo port install -y py38-flask
sudo apt-get install -y gunicorn
sudo apt-get install -y python3-setproctitle
sudo apt-get install -y python3-flask

echo "------------------------------------"
cd ${TMPGIT}
git clone -o github https://github.com/evansd/whitenoise.git
cd whitenoise
sudo python setup.py install

echo "------------------------------------"
cd ${TMPGIT}
git clone -o github https://github.com/wg/wrk.git
cd wrk
make

cd ${ORIG}
