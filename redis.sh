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
        echo " $2 ...... $R FAILED $N"
        exit 1
    else
        echo " $2 ...... $G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]; then
    echo "$R Please login as a root user $N"
    exit 1
else
    VALIDATE $? "Logging as a root"
fi



dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG

VALIDATE $? "Installing redis remi repo"

dnf module enable redis:remi-6.2 -y &>> $LOG

VALIDATE $? "Enable Redis 6.2 from package streams"

dnf install redis -y &>> $LOG

VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOG

VALIDATE $? "Providing access permissions"

systemctl enable redis &>> $LOG

VALIDATE $? "Enabling redis service"

systemctl start redis &>> $LOG

VALIDATE $? "Starting redis service"