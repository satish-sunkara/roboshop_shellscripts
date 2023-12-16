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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOG

VALIDATE $? "Configure YUM Repos from the script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOG

VALIDATE $? "Configure YUM Repos for RabbitMQ"

dnf install rabbitmq-server -y  &>> $LOG

VALIDATE $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> $LOG

VALIDATE $? "Enabling rabbitmq-server "

systemctl start rabbitmq-server  &>> $LOG

VALIDATE $? "Starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG

VALIDATE $? "Configuring user to rabbitmq-server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG

VALIDATE $? "Setting Permissions for rabbitmq-server"