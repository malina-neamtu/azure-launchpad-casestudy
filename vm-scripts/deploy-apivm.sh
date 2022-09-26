#!/bin/bash

while getopts "m:s:u:" arg; do
	case "${arg}" in
        m) mongoServer=${OPTARG} ;;
        s) sasToken=${OPTARG} ;;
		u) storageBaseUrl=${OPTARG} ;;
	esac
done

echo $mongoServer
echo $sasToken
echo $storageBaseUrl

cd ~
sudo curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt update 
sudo apt install -y nginx nodejs build-essential unzip
sudo npm install pm2@latest -g

sudo ufw allow 'Nginx HTTP'

sudo systemctl stop nginx
sudo cat <<EOF > ratingapp
server {
    listen 80;
    listen [::]:80;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        #proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        #proxy_set_header Host $host;
        #proxy_cache_bypass $http_upgrade;
    }
}
EOF
sudo cp ratingapp /etc/nginx/sites-available/ratingapp
sudo ln -s /etc/nginx/sites-available/ratingapp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl start nginx
sudo pm2 stop rating-api
sudo mkdir /var/www/api/
sudo curl -sL "${storageBaseUrl}/api.zip${sasToken}" -o api.zip
sudo unzip api.zip -d /var/www/api/
sudo chmod 755 -R /var/www/api/
cd /var/www/api/
sudo npm install

PORT='3000' MONGODB_URI="mongodb://${mongoServer}:27017/webratings" pm2 start /var/www/api/bin/www --name rating-api



