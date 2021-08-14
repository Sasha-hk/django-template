#!/bin/bash 

domain_name=""
project_name="" 
base_dir=$(pwd) 
user=""

echo -n 'Enter domain name, for example google.com: '
read domain_name

echo -n 'Enter project name: '
read project_name

echo -n 'Enter user to run gunicorn: '
read user 


proxy_pass="http://unix:$base_dir/src/$project_name.sock"


virtualenv env/env
source env/env/bin/activate
pip install -r env/requirements.txt


sed -i "s%domain_name_replace%$domain_name%g" env/nginx/project1
sed -i "s%proxy_pass_replace%$proxy_pass%g" env/nginx/project1  

mv env/nginx/project1 env/nginx/$project_name

sed -i "s%base_dir_replace%$base_dir%g" env/gunicorn/project1.service env/gunicorn/project1.socket
sed -i "s%project_name_replace%$project_name%g" env/gunicorn/project1.service env/gunicorn/project1.socket
sed -i "s%user_replace%$user%g" env/gunicorn/project1.service

mv env/gunicorn/project1.service env/gunicorn/$project_name.service
mv env/gunicorn/project1.socket env/gunicorn/$project_name.socket

sed -i "s%domain_name_replace%$domain_name%g" src/config/settings.py

ln -s $base_dir/env/gunicorn/$project_name.service /etc/systemd/system 
ln -s $base_dir/env/gunicorn/$project_name.socket /etc/systemd/system 

ln -s $base_dir/env/nginx/$project_name /etc/nginx/sites-enabled