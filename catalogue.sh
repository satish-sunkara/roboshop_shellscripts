#!/bin/bash

USERID=$(id -u)
DATE=$(date +%F_%H-%M-%S)
LOG="/tmp/$0-$DATE.log"

if [ $USERID -ne 0 ]; then
    echo " Please login as root user"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo " $2 ..... FAILED"
        exit 1
    else
        echo " $2 ..... SUCCESS"
}

dnf module disable nodejs -y &>> $LOG

VALIDATE $? "Disabling existing nodejs versiom"

dnf module enable nodejs:18 -y &>> $LOG

VALIDATE $? "Enabling Required nodejs:18 version"

dnf install nodejs -y &>> $LOG

VALIDATE $? "Installing nodejs"

useradd roboshop &>> $LOG

VALIDATE $? "Creating the User "

mkdir /app &>> $LOG

VALIDATE $? "Creating app directory "

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG

VALIDATE $? "Downloading catalogue zip code"

cd /app  &>> $LOG

VALIDATE $? "Navigating to app directory"

npm install &>> $LOG

VALIDATE $? "Installing Dependencies"

cp -r catalogue.service /etc/systemd/system/catalogue.service &>> $LOG

VALIDATE $? " Copying catalogue services"

systemctl daemon-reload &>> $LOG

VALIDATE $? "systemctl daemon-reload"

systemctl enable catalogue &>> $LOG

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOG

VALIDATE $? "Starting catalogue"

cp -r mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG

VALIDATE $? "Coping mongo repo"

dnf install mongodb-org-shell -y &>> $LOG

VALIDATE $? "Installing mongo third-party shell"

mongo --host 172.31.40.237 </app/schema/catalogue.js &>> $LOG

VALIDATE $? "Dupping catalogue data to mongodb"
