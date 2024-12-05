#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started at $TIMESTAMP" &>> $LOGFILE

RED="\e[31m"
G="\e[32m"
Yel="\e[33m"
NORMAL="\e[0m"



VALIDATE(){
    if [ $1 = 0 ]
    then 
      echo -e "$2... $G Sucessful $NORMAL"    
    else
      echo -e "$2...$RED failed $NORMAL"
      exit 1
    fi
}

if [ $ID != 0 ]
then
 echo -e "Error: $RED Pleae run as root user $NORMAL"
 exit 1 
else 
 echo "Suessful: You are a root user"
fi

dnf module disable mysql -y  &>> $LOGFILE
VALIDATE $? "Disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo  &>> $LOGFILE
VALIDATE $? "Copying the repo"

dnf install mysql-community-server -y  &>> $LOGFILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld  &>> $LOGFILE
VALIDATE $? "Enabling mysqld"

systemctl start mysqld  &>> $LOGFILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1  &>> $LOGFILE
VALIDATE $? "Mysql password"
