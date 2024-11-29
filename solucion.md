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

  ![Imagen1](/imagenes/imagen1_1.png)

Ficheiro dhcp4.json

~~~
{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": ["eth0"],
            "dhcp-socket-type": "raw"
        },
        "valid-lifetime": 7200,
        "renew-timer": 7000,
        "rebind-timer": 7100,
        "subnet4": [
            {
                "id": 1,
                "subnet": "192.168.10.0/24",
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
                        "name": "routers",
                        "data": "192.168.10.254",
                        "always-send": true
                    }
                ]
            },
            {
                "id": 2,
                "subnet": "192.168.11.0/24",
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
                        "output": "/var/log/dhcp.log"
                    }
                ],
                "severity": "INFO",
                "debuglevel": 0
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

  ![Imagen1](/imagenes/imagen2_1.png)

Ficheiro named.conf.local:

~~~
key "updatekey" {
    algorithm hmac-md5;
    secret "OfdzJnfDOCU40zp5vleiTcPPEtht1p5Zj/v8p7z5Gg0=";
};

zone "stark.lan" {
    type master;
    file "/etc/bind/db.stark.lan";
    allow-update { key "OfdzJnfDOCU40zp5vleiTcPPEtht1p5Zj/v8p7z5Gg0="; };
};

zone "10.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.168.192";
    allow-update { key "OfdzJnfDOCU40zp5vleiTcPPEtht1p5Zj/v8p7z5Gg0="; };
};
~~~

Fichero named.conf.options: 

~~~
options {
	directory "/var/cache/bind";

	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable 
	// nameservers, you probably want to use them as forwarders.  
	// Uncomment the following block, and insert the addresses replacing 
	// the all-0's placeholder.

	//forwarders {
	//	0.0.0.0;
	//};

	//========================================================================
	// If BIND logs error messages about the root key being expired,
	// you will need to update your keys.  See https://www.isc.org/bind-keys
	//========================================================================
	dnssec-validation no;
	listen-on-v6 { none; };
};
~~~

Fichero de zona primaria:
~~~
$TTL 86400
@   IN  SOA arya.stark.lan. root.localhost. (
    2023101001 ; Serial
    3600       ; Refresh
    1800       ; Retry
    1209600    ; Expire
    86400 )    ; Minimum TTL

@       IN  NS      arya.stark.lan.
arya    IN  A       192.168.10.12
~~~

Ficheiro de zona secundaria:
~~~
$TTL 86400
@   IN  SOA arya.stark.lan. root.localhost. (
    2023101001 ; Serial
    3600       ; Refresh
    1800       ; Retry
    1209600    ; Expire
    86400 )    ; Minimum TTL

@   IN  NS     arya.stark.lan.
12  IN  PTR    arya.stark.lan.
~~~

**8.** Configura nos equipos ned e robb un servizo DHCP failover para a rede stark.lan  e para lannister.lan

**9.** Necesitarás polo menos catro clientes (bran, jon, sansha) para a rede stark e tres para a  rede lannister (jamie).

- Inclúe capturas de:
    - Configuración (grep -v "^#" /etc/dhcp/dhcpd.conf)
    - log de ned visualizando a asignación de enderezos en cada un dos pool e da reserva estática
    - Configuración de servidores DNS, router e enderezo IP de cada cliente
    - log de ned e robb (simultáneos) facendo unha actualización mediante chaves en arya.
    - log de ned visualizando asignacións da segunda subrede (lannister) e actualizacións no servidor dns correspondente.
    - Log dos dous servidores failover cando dous clientes obteñen enderezos
        - Os dous funcionan correctamente e os clientes renovan a concesión
        - O primeiro co cable desconectado e o segundo contectado, e os clientes renovan a concesión.
        - O primeiro co cable conectado e o segundo desconectado, e os clientes renovan a concesión.
    - Clientes tres dúas subredes, amosando DNS, router e enderezo IP.



