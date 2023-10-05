#! /bin/bash

apt install gnupg curl -y
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

if [[ $MAINLAND ]]; then
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] https://mirrors.tuna.tsinghua.edu.cn/mongodb/apt/debian bullseye/mongodb-org/6.0 main" | \
        tee /etc/apt/sources.list.d/mongodb-org-6.0.list
else
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | \
        tee /etc/apt/sources.list.d/mongodb-org-6.0.list
fi

apt update -y
apt install mongodb-org -y
