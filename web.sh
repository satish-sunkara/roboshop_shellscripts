#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F-%H-%S)

LOG="/tmp/$0-$DATE.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e " $2 ....... $R FAILED $N"
        exit 1
    else
        echo " $2 ....... $G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]; then
    echo -e " $R Please login as root user $N"
    exit 1
else
    VALIDATE $? "Loggin as a root"
fi

dnf install nginx -y

VALIDATE $? "Installing nginx"

systemctl enable nginx

VALIDATE $? "Enabling nginx service"

systemctl start nginx

VALIDATE $? "starting nginx service"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "Removing exixsting html code"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "Installing nginx"

cd /usr/share/nginx/html

VALIDATE $? "Changing Directory to the existing html code"

cp -r /home/centos/roboshop_shellscripts/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "Copying the roboshop config file to the defaultd folder"

systemctl restart nginx 

VALIDATE $? "Restarting  nginx"