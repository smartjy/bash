#!/bin/bash

MIRROR_SITE=apache.mirror.cdnetworks.com
SERVER=httpd
VERSION=2.4.41

URL=http://$MIRROR_SITE/$SERVER/$SERVER-$VERSION.tar.gz
conn_test() {
  ping -c 2  $MIRROR_SITE > /dev/null
  PRS=$?
  if [ "$PRS" != "0" ]
  then
    echo -e "# Can not connect to the download site \\n"
    exit ;
  fi
}

conn_test
wget $URL



#http://apache.mirror.cdnetworks.com//httpd/httpd-2.4.41.tar.gz
