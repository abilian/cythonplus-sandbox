# if gcc used in script, script needs shopt -s expand_aliases
alias gcc='gcc-mp-7'
alias cc='gcc-mp-7'
alias g++='g++-mp-7'
alias c++='g++-mp-7'

export CC=/opt/local/bin/gcc-mp-7
export CXX=/opt/local/bin/g++-mp-7
export CPP=/opt/local/bin/g++-mp-7
export LD=/opt/local/bin/g-mp-7

echo "gcc alias set."
