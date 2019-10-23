#!/bin/bash

VERSION=8.5
DIR=$(pwd)
INSTANCE_NAME=
LOGHOME=/logs/tomcat

if [ -z $INSTANCE_NAME ]; then
  echo -n "Input unique INSTANCE_NAME(or SERVER_NAME) (ex tomcat-svr-11, tomcat-11): ";
  read word;
  if [ -z $word ]; then
    echo "# [ERROR]  have to Input INSTANCE_NAME(or SERVER_NAME)!!! "
    exit ;
  fi
    INSTANCE_NAME="$word";
    SVR_NAME=$INSTANCE_NAME;
    SVR_PATH=$DIR/$SVR_NAME;
    echo "INSTANCE_NAME = $SVR_NAME";
    echo "INSTANCE_PATH = $SVR_PATH";
    `mkdir -p $SVR_PATH`;
  else
    SVR_PATH=$DIR/$INSTANCE_NAME;
    `mkdir -p $SVR_PATH`;
fi

if [ ! -z $LOGHOME ]; then
  `ln -s $LOGHOME $DIR/$INSTANCE_NAME/logs`
fi

# -----------------------------------------------------------------
# Make Directory
# -----------------------------------------------------------------
[ ! -d "$INSTANCE_NAME/bin" ]     &&  mkdir -p $INSTANCE_NAME/bin;
[ ! -d "$INSTANCE_NAME/conf" ]    &&  mkdir -p $INSTANCE_NAME/conf;
[ ! -d "$INSTANCE_NAME/lib" ]     &&  mkdir -p $INSTANCE_NAME/lib;
[ ! -d "$INSTANCE_NAME/temp" ]    &&  mkdir -p $INSTANCE_NAME/temp;
[ ! -d "$INSTANCE_NAME/webapps" ] &&  mkdir -p $INSTANCE_NAME/webapps;
[ ! -d "$INSTANCE_NAME/work" ]    &&  mkdir -p $INSTANCE_NAME/work;

# -----------------------------------------------------------------
# XML Copy
# -----------------------------------------------------------------

value=`find ../ -type f -name "catalina.sh" 2>/dev/null | wc -l`
#echo $value

if [ -z ${value} ]; then
  echo "# [ERROR] Can not Found Tomcat Engine"
  else
  if [ ! -d $CATALINA_HOME ]; then
    echo "# [ERROR] Can not find CATALINA_HOME"
  else
    CATALINA_HOME=$(find ../ -type d -name "*$VERSION*" 2>/dev/null -exec readlink -f {} \;)
    cp -r $CATALINA_HOME/conf/* $SVR_PATH/conf/;
  fi
fi

# -----------------------------------------------------------------
# PORT, jvmRoute Translation Context
# -----------------------------------------------------------------
SOURCE=$CATALINA_HOME/conf/server.xml
TARGET=$SVR_PATH/conf/server.xml
DIFF=$(diff $SOURCE $TARGET)
if [ "$DIFF" ]; then
  echo "# [WARNING] $CATALINA_HOME/conf/server.xml and $SVR_PATH/conf/server.xml are different "
else
  sed -i 's/8005/\$\{shutdown.port\}/' $SVR_PATH/conf/server.xml;
  sed -i 's/8080/\$\{http.port\}/' $SVR_PATH/conf/server.xml;
  sed -i 's/8009/\$\{ajp.port\}/' $SVR_PATH/conf/server.xml;
  sed -i 's/8443/\$\{ssl.port\}/' $SVR_PATH/conf/server.xml;
  sed -i 's/8443/\$\{ssl.port\}/' $SVR_PATH/conf/server.xml;
  sed -i 's/"localhost">/"localhost" jvmRoute="${server}">/' $SVR_PATH/conf/server.xml;
  sed -i 's/directory\="logs"/directory\="${access.log}"/' $SVR_PATH/conf/server.xml;
  sed -i '/unpackWARs\|autoDeploy/a\      <Context path="" docBase="${apps.dir}" />' $SVR_PATH/conf/server.xml;

fi


