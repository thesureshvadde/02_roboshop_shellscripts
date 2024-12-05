#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started at $TIMESTAMP" &>> $LOGFILE

RED="\e[31m"
G="\e[32m"
Yel="\e[33m"
NORMAL="\e[0m"

MONGOIP=mongodb.sureshvadde.online

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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling"

dnf module enable nodejs:18 -y  &>> $LOGFILE
VALIDATE $? "Enabling"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing"

id roboshop
if [ $? -ne 0 ]
then 
   useradd roboshop
   VALIDATE $? "robo user creation"
else
   echo "user exits"
fi

VALIDATE $? "creating user"

mkdir -p /app &>> $LOGFILE  # -p if the app folder is available it will ignore if not create 
VALIDATE $? "Creatig app dir"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catloguge.zip"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE  # o is to overwrite
VALIDATE $? "Unzip"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm depncdies" 

cp /home/centos/Roboshop_Shellscripts/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "cp"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon loading"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "cenabling"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting"


cp /home/centos/Roboshop_Shellscripts/Mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installng shl"

mongo --host $MONGOIP </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "mg cnctd"


