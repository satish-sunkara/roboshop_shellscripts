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
    VALIDATE $USERID "Logging as root "
fi

dnf module disable mysql -y &>> $LOG

VALIDATE $? "Disable MySQL 8 version"

cp -r /home/centos/roboshop_shellscripts/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG

VALIDATE $? "Configuring mysql repo"

dnf install mysql-community-server -y &>> $LOG

VALIDATE $? "Installing MySQL 5.7 community server version"

systemctl enable mysqld &>> $LOG

VALIDATE $? "Enabling mysql services"

systemctl start mysqld &>> $LOG

VALIDATE $? "Enabling mysql services"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG

VALIDATE $? "Configuring mysql with root user and password"

mysql -uroot -pRoboShop@1 &>> $LOG

VALIDATE $? "Login to the mysql "