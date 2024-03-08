#! /bin/bash

USAGE="Usage: `basename $0` [-m|--mainland]"

MAINLAND=0

if [[ $# -gt 1 ]]; then
    echo -e "Too many arguments.\n$USAGE"
    exit 1
fi

if [[ ! -z "$1" ]]; then
    if [[ $1 == '-m' || $1 == '--mainland' ]]; then
        MAINLAND=1
    else
        echo -e "Invalid argument: $1.\n$USAGE"
        exit 1
    fi
fi

export MAINLAND

CUR_DIR=$(pwd)

BASEDIR=$(dirname $(realpath "$0"))

cd $BASEDIR

apt update -y
apt install ca-certificates curl gnupg lsb-release -y
apt install gdu tree jq tmux htop colorized-logs zip -y
apt install reptyr python3-pip python-is-python3 -y
apt install libssl-dev libboost-tools-dev libboost-dev libboost-system-dev -y
apt install aria2 -y


\cp ./.bashrc ~/.bashrc -f
\cp ./.tmux.conf ~/.tmux.conf -f

if [[ $MAINLAND ]]; then
    \cp ./.condarc ~/.condarc -f
fi

\cp ./.cargo ~/ -rf


if [[ $MAINLAND ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y
    echo $'\nexport RUSTUP_DIST_SERVER="https://rsproxy.cn"\nexport RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"\n' >> ~/.bashrc
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

. ~/.bashrc

source "$HOME/.cargo/env"

if [[ $MAINLAND ]]; then
    curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -s > miniconda.sh
else
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -s > miniconda.sh
fi

\sh ./miniconda.sh -b -f

source ~/miniconda3/bin/activate base

if [[ $MAINLAND ]]; then
    python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
else
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
fi

python -m pip install --upgrade pip

pip install numpy scipy matplotlib ipython pandas streamlit pymongo

conda init $(ps -p $$ -ocomm=)

# . ./mongodb.sh

cd $CUR_DIR
