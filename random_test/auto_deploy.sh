#/bin/bash

DATE=`date +%Y%m%d%H%M%S`
sub1=192; sub2=168; sub3=15; sub4=100
USER=root
PASSWD=root
WARNAME="test.war"

APPDIR="/opt/was/app"
SERVER_BASE="/opt/was/servers/tomcat8_21"
SSHOPTION="-oStrictHostKeyChecking=no"

SOURCE=$sub1.$sub2.$sub3.$sub4; 
TARGET=$SOURCE
echo "#############################################################";
echo "# INFO result [0] = SUCCESS or result [NOT 0] = FAIL ";
echo "# 0-0 $SOURCE SERVER APPLICATION GET THIS SERVER";
sshpass -p $PASSWD scp $USER@$SOURCE:/tmp/$WARNAME /tmp/$WARNAME ;
echo "# 0-0 Result: $?";
echo ""
echo "#############################################################";
echo "# CHECK WITH PING TO TARGET SERVER ";
echo "#############################################################";

while true
do
  cnt=1;
  sub4=`expr $sub4 + 100`;
  TARGET=$sub1.$sub2.$sub3.$sub4; 
	ping -c 1 -w 1  $TARGET >/dev/null 2>&1;
	if [ $? -ne 0 ]; then
    echo "#############################################################";
    echo "# NO LONGER TARGET: $TARGET ";
    echo "#############################################################";
		sleep 1;
	  break;
	else 
    echo "# TARGET [$cnt]: $TARGET ";
    echo "";
    
    echo "# TASKS Start ";
    
    echo "# 1-1 TARGET $TARGET [$cnt] APPLICATION BACKUP[move] ";
    sshpass -p $PASSWD  ssh $SSHOPTION $USER@$TARGET mv $APPDIR/test.war $APPDIR/test.war.$DATE;
    echo "# 1-2 Result: $?";
    echo ""
    
    echo "# 2-1 THIS SERVER to $TARGET [$cnt] SERVER APPLICATION COPY ";
    sshpass -p $PASSWD  scp /tmp/$WARNAME $USER@$TARGET:$APPDIR/$WARNAME; 
    echo "# 2-2 Result: $?";
    echo ""
    
    echo "# 3-1 $TARGET [$cnt] SERVER Shutdown ";
    sshpass -p $PASSWD  ssh -t $SSHOPTION $USER@$TARGET "cd $SERVER_BASE/bin; sudo -u wasuser ./kill.sh";
    echo "# Result: $?";
    echo ""
    
    echo "# 4-1 $TARGET [$cnt] SERVER Startup ";
    sshpass -p $PASSWD  ssh -t $SSHOPTION $USER@$TARGET "cd $SERVER_BASE/bin; sudo -u wasuser sh ./start.sh notail; sleep 5";
    echo "# Result: $?";
    echo ""
    echo "# TASKS END";
		sleep 1;
	  cnt=$((cnt + 1));
	fi
  echo "-------------------------------------------------------------";
	sleep 1;
	
done

