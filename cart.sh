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

VALIDATE $? "Disabling nodejs old module"

dnf module enable nodejs:18 -y &>> $LOG

VALIDATE $? "Enabling nodejs module:18"

dnf install nodejs -y &>> $LOG

VALIDATE $? "Install nodejs module:18"

id roboshop &>> $LOG

if [ $? -ne 0 ]; then
    usradd roboshop &>> $LOG
    VALIDATE $? "Creating the roboshop user "
else
    echo " User roboshop is already available $Y SKYPPING $N" &>> $LOG
fi

mkdir -p  /app &>> $LOG

VALIDATE $? "Creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOG

VALIDATE $? "Download the application code"

cd /app  &>> $LOG

unzip -o /tmp/cart.zip &>> $LOG

VALIDATE $? "Unzipping cart code file"

npm install  &>> $LOG

VALIDATE $? "Installing dependencies"

cp -r /home/centos/roboshop_shellscripts/cart.service /etc/systemd/system/cart.service &>> $LOG

VALIDATE $? "Coping cart service file to systemd"

systemctl daemon-reload &>> $LOG

VALIDATE $? "Cart daemon reload"

systemctl enable cart  &>> $LOG

VALIDATE $? "Enabling cart services"

systemctl start cart &>> $LOG

VALIDATE $? "Starting cart services"

