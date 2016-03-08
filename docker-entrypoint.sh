#!/bin/bash
set -e

# Generate self sign certificate
if [ ! -f $TASKDDATA/ca.cert.pem ]; then
  cd /var/taskd-1.1.0/pki
  ./generate
  cp *.pem $TASKDDATA
  taskd config --force client.cert $TASKDDATA/client.cert.pem
  taskd config --force client.key $TASKDDATA/client.key.pem
  taskd config --force server.cert $TASKDDATA/server.cert.pem
  taskd config --force server.key $TASKDDATA/server.key.pem
  taskd config --force server.crl $TASKDDATA/server.crl.pem
  taskd config --force ca.cert $TASKDDATA/ca.cert.pem
  taskd config --force log $TASKDDATA/taskd.log
  taskd config --force pid.file $TASKDDATA/taskd.pid
  taskd config --force server 0.0.0.0:53589
fi

exec "$@"
