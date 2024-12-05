## Servidores DHCP Windows

Dado o seguinte escenario:

  ![Imagen0](/imagenes/imagen0.png)

O equipo arya será o servidore dns para o dominio stark.lan lannister.lan e targaryen.lan

Instala no equipo ned (Debian) un servidor DHCP coa seguinte configuración:

---

**1.** Unha subrede para os equipos da rede privada stark.lan 192.168.10.0/24 con 2 pool. Un dos pool, asignará enderezos no rango entre .30 e .32 e outro no rango entre .101 e .230. Estes deberán ter como único servidor dns ao equipo arya

**2.** Unha subrede para os equipos da rede privada lannister.lan 192.168.11.0/24

**3.** Unha subrede para os equipos da rede privada targaryen.lan 192.168.57.0/24  (Conectado ao interface cloud sobre vboxnet1)

**4.** Fai que os log, se amosen no ficheiro /var/log/dhcp.log

**5.** Deberás crear unha reserva estática que estará no rango de enderezos do seu pool correspondente (para o equipo bran)

**Configuración de NED - Resultado do exercicio 1,2,3,4 e 5:**

Ficheiro entrypoint.sh:

  ![Imagen1_1](/imagenes/imagen1_1.png)

Ficheiro dhcp4.json

~~~
{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": ["eth0"],
            "dhcp-socket-type": "raw"
        },
        "dhcp-ddns": { "enable-updates": true },
        "valid-lifetime": 7200,
        "renew-timer": 7000,
        "rebind-timer": 7100,
        "subnet4": [
            {
                "id": 1,
                "subnet": "192.168.10.0/24",
                "ddns-qualifying-suffix": "stark.lan",
                "pools": [
                    { "pool": "192.168.10.30-192.168.10.32" },
                    { "pool": "192.168.10.101-192.168.10.230" }
                ],
                "reservations": [
                    {
                        "hw-address": "0a:13:1d:5a:b7:61",
                        "ip-address": "192.168.10.31"
                    }
                ],
                "relay": {
                    "ip-address": "192.168.10.254"
                },
                "option-data": [
                    {
                        "name": "domain-name-servers",
                        "data": "192.168.10.12",
                        "always-send": true
                    },
                    {
                        "name": "domain-name",
                        "data": "stark.lan",
                        "always-send": true
                    },
                    {
                        "name": "routers",
                        "data": "192.168.10.254",
                        "always-send": true
                    }
                ]
            },
            {
                "id": 2,
                "subnet": "192.168.11.0/24",
                "ddns-qualifying-suffix": "lannister.lan",
                "pools": [
                    { "pool": "192.168.11.101-192.168.11.230" }
                ],
                "relay": {
                    "ip-address": "192.168.11.254"
                },
                "option-data": [
                    {
                        "name": "domain-name-servers",
                        "data": "192.168.10.12",
                        "always-send": true
                    },
                    {
                        "name": "domain-name",
                        "data": "lannister.lan",
                        "always-send": true
                    },
                    {
                        "name": "routers",
                        "data": "192.168.11.254",
                        "always-send": true
                    }
                ]
            },
            {
                "id": 3,
                "subnet": "192.168.57.0/24",
                "pools": [
                    { "pool": "192.168.57.101-192.168.57.230" }
                ],
                "relay": {
                    "ip-address": "192.168.57.254"
                },
                "option-data": [
                    {
                        "name": "domain-name-servers",
                        "data": "192.168.10.12",
                        "always-send": true
                    },
                    {
                        "name": "routers",
                        "data": "192.168.57.254",
                        "always-send": true
                    }           
                ]
            }
        ],
        "loggers": [
            {
                "name": "kea-dhcp4",
                "output_options": [
                    {
                        "output": "/var/log/dhcp.log",
                        "maxver": 8,
                        "maxsize": 204800,                        
                        "flush": true
                    }
                ],
                "severity": "INFO"
            }
        ]
    }
}
~~~

---

**6.** Debe actualizar mediante chaves a zona primaria (directa e inversa) no servidor DNS arya.

**7.** Establece os nomes de dominio e servidores DNS  de cada zona.

**Configuración de ARYA - Resultado do exercicio 6 e 7:**

Ficheiro entrypoint.sh:

  ![Imagen2_1](/imagenes/imagen2_1.png)

Ficheiro named.conf.local:

~~~
key "chaveupdate" {
	algorithm hmac-sha256;
	secret "x6LA1vDz1ITA+trpFY1ouW3gHxu7M0Z/xXCI9eOgJhI=";
};
zone "stark.lan" {
    type master;
    file "db.stark.lan";
    allow-update {key "chaveupdate";};
};
zone "10.168.192.in-addr.arpa" {
    type master;
    file "db.192.168.10";
    allow-update {key "chaveupdate";};
};

zone "lannister.lan" {
    type master;
    file "db.lannister.lan";
    allow-update {key "chaveupdate";};
};
zone "11.168.192.in-addr.arpa" {
    type master;
    file "db.192.168.11";
    allow-update {key "chaveupdate";};
};
~~~

Otros ficheros: 

  ![Imagen2_2](/imagenes/imagen2_2.png)

**8.** Configura nos equipos ned e robb un servizo DHCP failover para a rede stark.lan  e para lannister.lan

Non facer

**Configuración do router para que funcione como relay**

Ficheiro entrypoint.sh:

  ![Imagen3_1](/imagenes/imagen3_1.png)

Ficheiro isc-dhcp-relay:

~~~
# Defaults for isc-dhcp-relay initscript
# sourced by /etc/init.d/isc-dhcp-relay
# installed at /etc/default/isc-dhcp-relay by the maintainer scripts

#
# This is a POSIX shell fragment
#

# What servers should the DHCP relay forward requests to?
SERVERS="192.168.10.10"

# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES="eth1 eth2 eth3"

# Additional options that are passed to the DHCP relay daemon?
OPTIONS=""
~~~

**9.** Necesitarás polo menos catro clientes (bran, jon, sansha) para a rede stark e tres para a  rede lannister (jamie).

- Inclúe capturas de:
    - Configuración (grep -v "^#" /etc/dhcp/dhcpd.conf)

    ![Imagen4_1](/imagenes/imagen4_1.png)

    - log de ned visualizando a asignación de enderezos en cada un dos pool e da reserva estática

    ![Imagen4_2](/imagenes/imagen4_2.png)

    - Configuración de servidores DNS, router e enderezo IP de cada cliente

    - log de ned e robb (simultáneos) facendo unha actualización mediante chaves en arya.

    - log de ned visualizando asignacións da segunda subrede (lannister) e actualizacións no servidor dns correspondente.

    - Log dos dous servidores failover cando dous clientes obteñen enderezos
        - Os dous funcionan correctamente e os clientes renovan a concesión
        - O primeiro co cable desconectado e o segundo contectado, e os clientes renovan a concesión.
        - O primeiro co cable conectado e o segundo desconectado, e os clientes renovan a concesión.

    - Clientes tres dúas subredes, amosando DNS, router e enderezo IP.

    Cliente en red stark.lan:

    ![Imagen4_3](/imagenes/imagen4_3.png)
    
    Cliente en red lannister.lan:

    ![Imagen4_2](/imagenes/imagen4_4.png)
    
    Cliente en red targaryen.lan:

    ![Imagen4_5](/imagenes/imagen4_5.png)



