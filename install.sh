#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
PINK=`tput setaf 5`
CYAN=`tput setaf 6`
None=`tput sgr0`

domain_name=""
project_name=""
user_to_run_gunicorn=""
gunicorn_workers_count=0 
base_dir="$PWD"

echo "${RED}[!]${None} You must have installed:
    - nginx
    - gunicotn\n
${RED}[!]${None} Elso make .env file with enviroment variables on env directory You can use ${GREEN}.env.template${None}\n"


# Get neded variables

echo -n "${CYAN}[+]${None} Enter domain name, for example 'google.com': "
read domain_name 

echo -n "${CYAN}[+]${None} Enter project name, for example 'google': "
read project_name

echo -n "${CYAN}[+]${None} Enter user name, to run gunicorn: "
read user_to_run_gunicorn

echo -n "${CYAN}[+]${None} Enter count of workers for gunicorn: "
read gunicorn_workers_count 



# replace domain name on setting.py

sed -i "s/domain_name_replace/${domain_name}/g" src/config/settings.py



# Create and activate virtualenviroment

cd env
virtualenv env
. env/bin/activate

echo "\n${GREEN}Installing packages${None}"

pip install -r requirements.txt



# Create and fill server files

mkdir nginx systemd
mkdir -p systemd/log

path_to_sock_file="/run/$project_name.sock"



## NGINX
echo "server {
    listen 80;
    server_name $domain_name;
    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root $base_dir/src;
    }  
    location / {
        include proxy_params;
        proxy_pass http://unix:$path_to_sock_file;
    }
}" >> nginx/$project_name

## systemd / Gunicorn
echo "[Unit]
Description=gunicorn socket
[Socket]
ListenStream=$path_to_sock_file
[Install]
WantedBy=sockets.target" >> systemd/$project_name.socket

echo "[Unit]
Description=gunicorn daemon
Requires=$project_name.socket
After=network.target
[Service]
EnvironmentFile=$base_dir/env/.env
User=$user_to_run_gunicorn
Group=$user_to_run_gunicorn
WorkingDirectory=$base_dir/src
ExecStart=$base_dir/env/env/bin/gunicorn --error-logfile $base_dir/env/systemd/log/error.log --access-logfile $base_dir/env/systemd/log/access.log --workers $gunicorn_workers_count  --bind unix:$path_to_sock_file config.wsgi:application  
[Install]
WantedBy=multi-user.target" >> systemd/$project_name.service



# Creating a symbolic link for server files
echo "\n${YELLOW}[?]${None} Now we need to set some files which need root access"

su -c "ln -s $base_dir/env/nginx/$project_name /etc/nginx/sites-enabled
ln -s $base_dir/env/systemd/$project_name.socket /etc/systemd/system
ln -s $base_dir/env/systemd/$project_name.service /etc/systemd/system
service nginx restart
systemctl daemon-reload
systemctl enable $project_name
systemctl restart $project_name"  


echo "\n${GREEN}[+] Probably all done !${None}
    You can check ${CYAN}service nginx status${None}
    and ${CYAN}systemctl status ${project_name}${None}"


cd ..