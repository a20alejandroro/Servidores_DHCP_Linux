#!/bin/bash

RUTA=$(dirname "$(realpath "$0")")

cp "$RUTA/dhcp4.json" /etc/kea/kea-dhcp4.conf
chmod a+r /etc/kea/kea-dhcp4.conf

cp "$RUTA/ddns.json" /etc/kea/kea-ddns.conf
chmod a+r /etc/kea/kea-ddns.conf

/etc/init.d/kea-dhcp4-server restart
/etc/init.d/kea-dhcp-ddns-server restart

touch /var/log/dhcp.log
chmod 644 /var/log/dhcp.log


