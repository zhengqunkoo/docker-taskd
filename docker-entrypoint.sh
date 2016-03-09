#!/bin/bash

set -e

set $PKI=$TASKDDATA"/pki"

if [ ! -d $PKI ]; then
  ln -s /var/taskd-$TASKD_VERSION/pki /var/taskd/pki
  taskd init
fi

# Generate self sign certificate if none exists
if [ ! -f $PKI/ca.cert.pem ]; then
  cd /var/taskd/pki

  if [ "$CERT_CN" ]; then
    sed -i "s/\(CN=\).*/\1$CERT_CN/" vars
  fi
  if [ "$CERT_ORGANIZATION" ]; then
    sed -i "s/\(ORGANIZATION=\).*/\1$CERT_ORGANIZATION/" vars
  fi
  if [ "$CERT_COUNTRY" ]; then
    sed -i "s/\(COUNTRY=\).*/\1$CERT_COUNTRY/" vars
  fi
  if [ "$CERT_STATE" ]; then
    sed -i "s/\(STATE=\).*/\1$CERT_STATE/" vars
  fi
  if [ "$CERT_LOCALITY" ]; then
    sed -i "s/\(LOCALITY=\).*/\1$CERT_LOCALITY/" vars
  fi

  ./generate
  taskd config --force client.cert $PKI/client.cert.pem
  taskd config --force client.key $PKI/client.key.pem
  taskd config --force server.cert $PKI/server.cert.pem
  taskd config --force server.key $PKI/server.key.pem
  taskd config --force server.crl $PKI/server.crl.pem
  taskd config --force ca.cert $PKI/ca.cert.pem
  taskd config --force log $TASKDDATA/taskd.log
  taskd config --force pid.file $TASKDDATA/taskd.pid
  taskd config --force server 0.0.0.0:53589
fi

if [ "$1" = 'taskd' -a "$(id -u)" = '0' ]; then
  chown -R taskd:taskd $TASKDDATA
  set -- gosu taskd "$@"
fi

exec "$@"
