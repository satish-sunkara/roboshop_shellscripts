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

dnf install golang -y &>> $LOG

VALIDATE $? "Installing golang"

id roboshop &>> $LOG

if [ $? -ne 0 ]; then
    useradd roboshop &>> $LOG
    VALIDATE $? "Creating the roboshop user "
else
    echo "User is already created ..... $Y SKIPPING $N"
fi

VALIDATE $? "Creating roboshop user"

mkdir /app  &>> $LOG
curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOG
cd /app &>> $LOG
unzip /tmp/dispatch.zip &>> $LOG

VALIDATE $? "Creating app directory and downloading,unzipping diapatch code"

cd /app  &>> $LOG
go mod init dispatch &>> $LOG
go get  &>> $LOG
go build &>> $LOG

VALIDATE $? "download the dependencies & building the software"

cp /home/centos/roboshop_shellscripts/dispatch.service  /etc/systemd/system/dispatch.service

VALIDATE $? "Validate and Configure dispatch.service"

systemctl daemon-reload &>> $LOG

VALIDATE $? "System daemon reload"

systemctl enable dispatch  &>> $LOG

VALIDATE $? "Enabling dispatch services"
 
systemctl start dispatch &>> $LOG

VALIDATE $? "Starting dispatch services"
