#!/bin/bash

RUTA=$(dirname "$(realpath "$0")")

cp ${RUTA}/named.conf.* /etc/bind/
cp ${RUTA}/zonas/* /var/cache/bind/
chmod a+r /etc/bind/named.conf.*
chmod a+rw /var/cache/bind/db.*

rsyslogd

/etc/init.d/named start
#tail -f /var/log/syslog