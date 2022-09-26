#!/bin/bash

while getopts "e:s:u:" arg; do
    case "${arg}" in
        s) sasToken=${OPTARG} ;;
        u) storageBaseUrl=${OPTARG} ;;
    esac
done

if ! systemctl is-active --quiet mongod
    then
    # Install MondoDB 5.0
        sudo apt-get install gnupg
        wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        sudo apt-get update
        sudo apt-get install -y mongodb-org unzip
        sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
        sudo systemctl enable mongod && sudo systemctl start mongod
    else
        echo "MongoDB already installed.."
fi

wget "${storageBaseUrl}/db.zip${sasToken}" -O db.zip
unzip db.zip -d ./db/
rm db.zip
chmod +x ./db/import.sh
./db/import.sh
rm -rf ./db/