#!/bin/bash

RUTA=$(dirname "$(realpath "$0")")
cp "$RUTA/isc-dhcp-relay" /etc/default/isc-dhcp-relay
/etc/init.d/isc-dhcp-relay restart
