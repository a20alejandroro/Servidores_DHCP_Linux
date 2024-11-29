#!/bin/bash
RUTA=$(dirname "$(realpath "$0")")
cp "$RUTA/named.conf.local" /etc/bind/named.conf.local
cp "$RUTA/named.conf.options" /etc/bind/named.conf.options
cp "$RUTA/db.stark.lan" /etc/bind/db.stark.lan
cp "$RUTA/named.conf.local" /etc/bind/db.10.168.192

/etc/init.d/named restart

rsyslogd

touch /var/log/syslog

tail -f /var/log/syslog