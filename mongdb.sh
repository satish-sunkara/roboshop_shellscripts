#!?bin/bash

USERID=$(id -u)
DATE=$(date +%F_%H:%M:%S)

LOG="/tmp/$0-$DATE.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

AVAILABLE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 .... $R FAILED $N "
    else
        echo -e "$2 .... $G SUCCESS $N "
    fi
}

if [ $USERID -ne 0 ]; then
    echo -e "$Y Please login as root user $N"
    exit 1
else
    VALIDATE $? "Logging as a root"
fi


cp -r mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG

AVAILABLE $? "Mongo repo copied" 

dnf install mongodb-org -y &>> $LOG

AVAILABLE $? "Mongodb Installation"

systemctl enable mongod &>> $LOG

AVAILABLE $? "Enabling Mongodb"

systemctl start mongod &>> $LOG

AVAILABLE $? "Starting  Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG

AVAILABLE $? "Appling the changes "

systemctl restart mongod  &>> $LOG

AVAILABLE $? "Restarting Mongodb "


