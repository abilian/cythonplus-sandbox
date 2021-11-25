# if gcc used in script, script needs shopt -s expand_aliases

function make_macports_gcc_alias {
    [[ "$1" == "0" ]] && return
    alias gcc="gcc-mp-$1"
    alias cc="gcc-mp-$1"
    alias g++="g++-mp-$1"
    alias c++="g++-mp-$1"

    export CC="/opt/local/bin/gcc-mp-$1"
    export CXX="/opt/local/bin/g++-mp-$1"
    export CPP="/opt/local/bin/g++-mp-$1"
    export LD="/opt/local/bin/g-mp-$1"
    echo "gcc alias set to ${CC}."
}

which -s port && {
    # 'port' detected, find if any gcc installed with macports
    found=0
    for i in 7 8 9 10 11; do
        which -s "gcc-mp-${i}" && { found=${i}; break; }
    done
    make_macports_gcc_alias ${found}
}
