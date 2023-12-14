#!?bin/bash

USERID=$(id -u)
DATE=$(date +%F_%H:%M:%S)

LOG="/tmp/$0-$DATE.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$Y Please login as root user $N"
    exit 1
fi


