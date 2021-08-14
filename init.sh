#!/bin/bash 

domain_name=""
project_name="" 
base_dir=$(pwd) 
user=""

echo -n 'Enter domain name: '
read domain_name

echo -n 'Enter project name: '
read project_name

echo -n 'Enter user to run gunicorn: '
read user 

# path_to_project="$base_dir/$project_name"
proxy_pass="http://unix:$base_dir/src/$project_name.sock"



# domain_name_replace
# proxy_pass_replace
# base_dir_replace
sed -i "s%domain_name_replace%$domain_name%g" env/nginx/project1
sed -i "s%proxy_pass_replace%$proxy_pass%g" env/nginx/project1  

mv env/nginx/project1 env/nginx/project_name

sed -i "s%base_dir_replace%$base_dir%g" env/gunicorn/project1.service env/gunicorn/project1.socket
sed -i "s%project_name_replace%$project_name%g" env/gunicorn/project1.service env/gunicorn/project1.socket
sed -i "s%user_replace%$user%g" env/gunicorn/project1.service

mv env/gunicorn/project1.service env/gunicorn/project_name.service
mv env/gunicorn/project1.socket env/gunicorn/project_name.socket




# virtualenv env/env
# source env/env/bin/activate
# pip install -r env/requirements.txt







# add domain name to allowed hosts 

# rename ptoject1 to project name
# rename name files of all files to project name


# start gunicorn service 
# enable gunicorn service 



