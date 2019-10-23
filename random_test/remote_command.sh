#!/bin/sh

SERVER_IP=192.168.15.100
SERVER_BASE=/opt/was/servers/tomcat8_11
USER=wasuser


STATUS=`ps -ef | grep "java" | grep "tomcat"`
$STATUS

if [ $? -eq 0 ]; then
 echo "#############################################"
 echo "TOMCAT Server is [ running]. "
 echo "#############################################"
 echo "If you want to stop input: [2]"
 echo "#############################################"
 echo -e "What is your answser?: ";
 read num;

  if [ $num -eq 2 ]; then 

     sshpass -p root ssh -t root@$SERVER_IP "cd $SERVER_BASE/bin; sudo -u $USER ./kill.sh"
  else 
    exit
  fi

  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "TOMCAT Server is [ shutdown ]. "
  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "If you want to start input: [1]"
  echo "#############################################"
  echo -e "What is your answser?: ";
  read num;

    if [ $num -eq 1 ]; then 

      sshpass -p root ssh -t root@$SERVER_IP "cd $SERVER_BASE/bin; sudo -u $USER ./start.sh notail"
    else 
      exit
    fi
fi

