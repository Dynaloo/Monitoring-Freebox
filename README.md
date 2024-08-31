# Monitoring de votre Freebox avec Telegraf & InfluxDB-v1 ou v2 & Grafana
L'objectif étant de simplifier la configuration avec des variables d'environnement dans le "docker compose". Cette nouvelle image est basée sur le travail de "Uzurka" (https://hub.docker.com/r/uzurka/freebox-telegraf).

> **Voir ci-dessous le fichier "docker-compose"**

> Le point d'entrée vérifie la présence du fichier ``/usr/local/py/.credentials``.

Si le fichier n'est pas présent, il lancera automatiquement l'enregistrement de l'application sur la freebox.

> En cas d'échec de cette inscription, faire la commande suivante : ``docker exec -it container_name rm /usr/local/py/.credentials`` et redémarrez le conteneur pour relancer l'enregistrement

#### Ici, un exemple de ce que vous pouvez obtenir avec grafana :

[grafana](https://github.com/dynaloo/monitoring-freebox/blob/main/Exemple-Grafana.png)

## Architectures disponibles
- amd64
- arm64 (aarch64)
- armv7 (arm)

# Installation sur container docker

- Créer le fichier docker-compose.yaml et faire les modifications du fichier avec vos informations et le choix de la version Influxdb, puis : run ``docker-compose up -d``

ou

- Avec "Portainer", créer une nouvelle stack avec le contenu du docker-compose, et modifier avec vos informations et le choix de la version Influxdb à utiliser. Puis "deploy the stack"

## Docker-compose
```
# Installation du monitoring de la freebox sous container Docker
  # Pré-requis : avoir docker & portainer operationnel sous Proxmox LXC
    # Avant de lancer la stack, créer les volumes & network ci-dessous avec portainer #
      # docker volume create influxdb
      # docker volume create influxdb-v2
      # docker volume create grafana
      # docker network create monitoring_network
    # deployer la stack apres avoir completer les infos d'environnement  #*

    # autre solution, créer des stacks separées pour Influxdb v1 et/ou influxdb v2, puis pour grafana, puis pour telegraf sans oublier de completer les infos d'environnement  #*

## Influxdb Version 2  ----------------------------------------------
#version: "3.8" # depreciated #
services:
  influxdb:
    image: influxdb:2.7.9
    container_name: influxdb-v2.7.x
    hostname: influxdb
    restart: unless-stopped
    ports:
      - '8086:8086'  # port par defaut pour accéder à l'interface web Influxdb_v2
#      - '8087:8086'  # port custom, remplace ci-dessus si influxdb-v1 tourne en parallele sur docker
    networks:
      - monitoring_network
    volumes:
      - influxdb-v2:/var/lib/influxdb2  # volume pour stocker la base de données InfluxDB
      - /etc/influxdb2:/etc/influxdb2
networks:
  monitoring_network:
    external: true
volumes:
  influxdb-v2:
    external: true


## Influxdb Version 1  ----------------------------------------------
#version: "3.8" # depreciated #
services:
  influxdb:
    image: influxdb:1.8.10
    container_name: influxdb-v1.8.x
    hostname: influxdb
    restart: unless-stopped
    ports:
      - '8086:8086'  # port par defaut pour accéder à l'interface web Influxdb_v1.8.x
    networks:
      - monitoring_network
    volumes:
      - influxdb:/var/lib/influxdb  # volume pour stocker la base de données InfluxDB
      - /etc/influxdb:/etc/influxdb
networks:
  monitoring_network:
    external: true
volumes:
  influxdb:
    external: true     


## Telegraf  ---------------------------------------------------------
  # pour info, emplacement du fichier telegraf.conf : /etc/telegraf/
  # pour info, emplacement du fichier freebox-monit.py : /usr/local/py/
  ## donner l'autorisation sur la freebox apres le lancement de la stack 

#version: "3.8" # depreciated #
services:
  fbx_telegraf:
    image: dynaloo13/freebox-telegraf:v.1.0
    container_name: freebox-telegraf
    hostname: telegraf
    restart: unless-stopped
    ports:
      - 9125:8125/udp
      - 9092:8092/udp
      - 9094:8094
    networks:
      - monitoring_network
    environment:
      - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin:/usr/local:/usr/src
      - TZ=europe/paris
      - TELEGRAF_AGENT_INTERVAL=10s
      - TELEGRAF_SCRIPT_TIMEOUT=5s
      - TELEGRAF_DATA_FORMAT=influx

      - INFLUXDB_URL=http://votre_IP_docker:8086  #*
      - INFLUXDB_DATABASE=nom_de_votre_bdd  #*
      - INFLUXDB_SKIP_DATABASE_CREATION=false
      - INFLUXDB_USER=votre_user_bdd  #*
      - INFLUXDB_PASSWORD=votre_password_bdd  #*

      - ARGS=SPHDLWIXYZ

#      - INFLUXDB2_URL=http://votre_IP_docker:8086  # ou :8087 si les 2 versions (v1 et v2) d'influxdb sont installées  #*
#      - INFLUXDB2_TOKEN=votre_token_influxdb2  #*
#      - INFLUXDB2_SKIP_DATABASE_CREATION=true
#      - INFLUXDB2_ORG=votre_organisation  #*
#      - INFLUXDB2_BUCKET=votre_bucket  #*

networks:
  monitoring_network:
    external: true


## Grafana  --------------------------------------------------------------
#version: "3.8" # depreciated #
services:
  grafana:
    image: grafana/grafana-oss
    container_name: grafana
    hostname: grafana
    restart: unless-stopped
    ports:
      - '3000:3000'
    networks:
      - monitoring_network
    volumes:
      - grafana:/var/lib/grafana  # volume pour stocker la base de données Grafana
networks:
  monitoring_network:
    external: true
volumes:
  grafana:
    external: true
```

## Configuration

### Ports exposées

- 8092/udp

- 8094/tcp

- 8125/udp


### Variable d'environement
| Environment variable            | Exemple                                 | Usage                                                                                                                                                                                 |
|---------------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| TZ                              | CET                                     | Set your TimeZone into the container                                                                                                                                                  |
| INFLUXDB_URL                    | http://influxdb_container_hostname:port | Set the InfluxDB URL so the container can write metrics into it                                                                                                                       |
| INFLUXDB_DATABASE               | Freebox                                 | The name of the database Telegraf will write on                                                                                                                                       |
| INFLUXDB_SKIP_DATABASE_CREATION | True/False                              | True : The database will not attempt to be created by the telegraf container False : The database will be created by the telegraf container, using USERNAME & PASSWORD provided below |
| INFLUXDB_USERNAME               | freebox                                 | Username for the InfluxDB database                                                                                                                                                    |
| INFLUXDB_PASSWORD               | MyStrongP@ssw0rd!                       | Password used for the InfluxDB database                                                                                                                                               |
| ARGS                            | SPHDIWX4                                | See below                                                                                                                                                                             |
| TELEGRAF_AGENT_INTERVAL                            | 10s                                |defaults to 10s|
| TELEGRAF_SCRIPT_TIMEOUT                            | 5s                                |defaults to 5s|

### Arguments pour docker compose (ARGS=*xxxxxxxx*)
Ci-dessous les arguments utilisés pour exécuter le script python dans la configuration de Telegraf.

| Argument | Description                                   |
|----------|-----------------------------------------------|
| S        | Get and show switch status                    |
| P        | Get and show switch ports stats               |
| H        | Get and show system status                    |
| D        | Get and show internal disk usage              |
| L        | Get and show LAN config                       |
| W        | Get and show wifi usage                       |
| I        | Get and show lan interfaces                   |
| X        | Get and show interfaces hosts                 |
| Y        | Get and show static dhcp                      |
| Z        | Get and show dynamic dhcp                     |
| 4        | Get and show 4G/lte xdsl aggregation counters |

> Sélectionnez simplement les métriques souhaitées et ajoutez les lettres choisies à la variable :  ARGS=*SPHDLW* dans docker compose

Pour info, la variable d'environnement ARGS est présent dans le fichier telegraf.conf ``"/usr/local/py/freebox-monit.py -${ARGS}"``.
