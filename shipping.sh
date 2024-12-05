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
 echo "Error: $RED Pleae run as root user $NORMAL"
 exit 1 
else 
 echo "Suessful: You are a root user"
fi

dnf install maven -y  &>> $LOGFILE
VALIDATE $? "Installing maven"

useradd roboshop  &>> $LOGFILE
VALIDATE $? "Adding robouser"

mkdir /app  &>> $LOGFILE
VALIDATE $? "Making app dir"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Curl command"

cd /app &>> $LOGFILE
VALIDATE $? "Changing directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzip"

mvn clean package  &>> $LOGFILE
VALIDATE $? "Clean package"

mv target/shipping-1.0.jar shipping.jar  &>> $LOGFILE
VALIDATE $? "Renaming the shipping file"

cp /home/centos/Roboshop_Shellscripts/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copping shipping.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading daemon"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql"

mysql -h mysql.sureshvadde.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "Setting the mysql password"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping"