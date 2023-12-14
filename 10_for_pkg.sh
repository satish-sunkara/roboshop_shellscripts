#!/bin/bash

USRID=$(id -u)
DATE=$(date +%F_%H:%M:%S)
LOG="/tmp/$0-$DATE.log"

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USRID -ne 0 ]; then
    echo -e " $Y WARN:$R Please login as root user $N "
    exit 1
fi

AVAILABLE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 .... $R FAILED $N "
    else
        echo -e "$2 .... $G SUCCESS $N "
    fi
}


VALIDATE(){
    if [ $1 -ne 0 ]; then
        yum install $2 -y &>> $LOG
        AVAILABLE $? " Installation of $2"
    else
       echo -e " The package $2 is Already installed $Y SKIPPING $N"
    fi  
}

for i in $*; do
    # Validating package is installed or not
    yum list installed $i &>> $LOG 
    VALIDATE $? $i
done
#yum list installed git

#VALIDATE $? "GIT"
