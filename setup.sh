#! /bin/bash

CUR_DIR=$(pwd)

BASEDIR=$(dirname $(realpath "$0"))

cd $BASEDIR

apt update -y
apt install ca-certificates curl gnupg lsb-release -y
apt install gdu tree jq tmux htop colorized-logs -y
apt install reptyr python3-pip python-is-python3 -y
apt install libssl libssl-dev libboost-tools-dev libboost-dev libboost-system-dev -y


\cp ./.bashrc ~/.bashrc -f
\cp ./.condarc ~/.condarc -f

\cp ./.cargo ~/ -rf

. ~/.bashrc

curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y

source "$HOME/.cargo/env"

curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py311_23.5.2-0-Linux-x86_64.sh -s > miniconda.sh

sh ./miniconda.sh -b -f

source ~/miniconda3/bin/activate base
python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip install numpy scipy matplotlib ipython pandas streamlit pymongo

conda init $(ps -p $$ -ocomm=)

. ./mongodb.sh

cd $CUR_DIR
