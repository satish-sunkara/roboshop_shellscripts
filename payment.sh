#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F_%H-%M-%S)
LOG="/tmp/$0-$DATE.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e " $2 ........ $R FAILED $N"
        exit 1
    else
        echo -e " $2 ........ $G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]; then
    echo -e " $R Please log in as root user $N"
    exit 1
else
    VALIDATE $USERID "logning as root "
fi

dnf install python36 gcc python3-devel -y &>> $LOG

VALIDATE $?  "Install Python 3.6"

useradd roboshop &>> $LOG

VALIDATE $? "Creating a user"

mkdir /app  &>> $LOG

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG

VALIDATE $? "Creating app directory and downloading payment code" &>> $LOG

cd /app 

unzip /tmp/payment.zip &>> $LOG

pip3.6 install -r requirements.txt &>> $LOG

VALIDATE $? "Unzipping and Installing requirments "

cp -r /home/centos/roboshop_shellscripts/payment.service  /etc/systemd/system/payment.service &>> $LOG

VALIDATE $? "Copying and configuring payment.service"

systemctl daemon-reload &>> $LOG

VALIDATE $? "Syatem deamon reload"

systemctl enable payment  &>> $LOG

VALIDATE $? "Enabling payment service"

systemctl start payment &>> $LOG

VALIDATE $? "tarting payment service"
