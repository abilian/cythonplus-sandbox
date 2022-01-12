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
# sudo apt-get install -y gunicorn
# sudo apt-get install -y python3-setproctitle
# sudo apt-get install -y python3-flask

pip install gunicorn
pip install setproctitle
pip install flask

echo "------------------------------------"
cd ${TMPGIT}
[[ -d whitenoise ]] || git clone -o github https://github.com/evansd/whitenoise.git
cd whitenoise
python setup.py install

echo "------------------------------------"
cd ${TMPGIT}
[[ -d wrk ]] || git clone -o github https://github.com/wg/wrk.git
cd wrk
./wrk -v |grep 'wrk 4' || {
    git pull
    make
}
