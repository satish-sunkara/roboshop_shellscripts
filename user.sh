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
        echo -e " $2 ....... $G SUCCESS $N"
    fi
}



if [ $USERID -ne 0 ]; then
    echo -e " $R Please log in as root user $N"
    exit 1
else
    VALIDATE $USERID "logning as root "
fi 

dnf module disable nodejs -y &>> $LOG

VALIDATE $? "Disabling Old nodejs version"

dnf module enable nodejs:18 -y  &>> $LOG

VALIDATE $? "Enabling new nodejs:18 version"

dnf install nodejs -y   &>> $LOG

VALIDATE $? "Installing nodejs version"

id roboshop    &>> $LOG

if [ $? -ne 0 ]; then
    useradd roboshop &>> $LOG
    VALIDATE $? "Creatring roboshop User"
else
    echo "User roboshop is already exists $Y SKIPPING $N"
fi

VALIDATE $? "Creating a User"

mkdir -p /app   &>> $LOG
curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $LOG

VALIDATE $? "Creating app directory and Downloading User Code"

cd /app &>> $LOG
unzip -o /tmp/user.zip &>> $LOG
npm install &>> $LOG

VALIDATE $? "Unzipping and installing usr code under app directory"

cp -r  /home/centos/roboshop_shellscripts/user.service /etc/systemd/system/user.service &>> $LOG

VALIDATE $? "Creating and copying the user.servies"

systemctl daemon-reload &>> $LOG

VALIDATE $? "Daemn reload og user"

systemctl enable user  &>> $LOG

VALIDATE $? "Enabling the user services"

systemctl start user    &>> $LOG

VALIDATE $? "Strating the user services"

cp -r /home/centos/roboshop_shellscripts/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG

VALIDATE $? "Configuring the mongo.repo for mongodb client"

dnf install mongodb-org-shell -y &>> $LOG

VALIDATE $? "Installing mongodb client"

mongo --host mongodb.saachi.online </app/schema/user.js &>> $LOG                

VALIDATE $? "Pusshing schema to user.js"

