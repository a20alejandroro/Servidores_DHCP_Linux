#!/bin/bash

RUTA=$(dirname "$(realpath "$0")")

cp "$RUTA/dhcp4.json" /etc/kea/kea-dhcp4.conf
chown a+r /etc/kea/kea-dhcp4.conf

cp "$RUTA/ddns.json" /etc/kea/kea-dhcp-ddns.conf
chown a+r /etc/kea/kea-dhcp-ddns.conf

kea-dhcp4 -d -c /etc/kea/kea-dhcp4.conf &
kea-dhcp-ddns -d -c /etc/kea/kea-dhcp-ddns.conf

