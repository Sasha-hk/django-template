#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
PINK=`tput setaf 5`
CYAN=`tput setaf 6`
None=`tput sgr0`


# Create and activate virtualenviroment
virtualenv env
. env/bin/activate
echo "\n${GREEN}Installing packages${None}"
pip install -r requirements.txt