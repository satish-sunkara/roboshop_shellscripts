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

dnf install maven -y &>> $LOG

VALIDATE $? "java installation"

id roboshop &>> $LOG

if [ $? -ne 0 ]; then
    useradd roboshop &>> $LOG
    VALIDATE $? "Creating a roboshop user"
else
    echo "User roboshop is already exists $Y SKIPPING $N"
fi

VALIDATE $? "Creating a roboshop user"

mkdir -p /app &>> $LOG

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG

VALIDATE $? "Creating a app directory and downloading shipping.zip code file"

cd /app &>> $LOG

unzip -o /tmp/shipping.zip &>> $LOG

mvn clean package &>> $LOG

VALIDATE $? "Unzipping and Installing the Java package"

mv target/shipping-1.0.jar shipping.jar &>> $LOG

cp -r /home/centos/roboshop_shellscripts/shipping.service /etc/systemd/system/shipping.service &>> $LOG

VALIDATE $? " Copying shipping.service folder to systemd"

systemctl daemon-reload &>> $LOG

VALIDATE $? "shipping daemon reloading "

systemctl enable shipping  &>> $LOG

VALIDATE $? "Enabling shippping services"

systemctl start shipping &>> $LOG

VALIDATE $? "Starting shipping services"

dnf install mysql -y &>> $LOG

VALIDATE $? "Installing mysql client"

mysql -h mysql.saachi.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOG

VALIDATE $? "Creating username/password to  mysqldb"

systemctl restart shipping &>> $LOG

VALIDATE $? "Restarting mysql services"