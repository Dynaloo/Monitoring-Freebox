# Monitoring de votre Freebox avec Telegraf & InfluxDB
Également disponible sur Docker-Hub (https://hub.docker.com/r/uzurka/freebox-telegraf)

Ce travail est basé sur l'image Docker de Telegraf (https://hub.docker.com/_/telegraf)

Et le tuto de Bruno78, pour une installation sur NAS Synology (https://www.nas-forum.com/forum/topic/66394-tuto-monitorer-sa-freebox-revolution/)

L'objectif est de simplifier la configuration avec des variables d'environnement dans docker compose.

Le point d'entrée vérifie la présence du fichier ``/usr/local/py/.credentials``.

Si le fichier n'est pas présent, il lancera automatiquement l'enregistrement de l'application sur la freebox.

En cas d'échec de cette inscription, faire la commande suivante ``docker exec -it container_name rm /usr/local/py/.credentials`` et redémarrez le conteneur pour relancer l'enregistrement

#### Ici, un exemple de ce que vous pouvez obtenir avec grafana : 
![Grafana](https://github.com/dynaloo/monitoring-freebox/blob/main/Exemple-Grafana.png)

## Architectures disponibles
- amd64
- arm64 (aarch64)
- armv7 (arm)

## Installation sur container docker
Télécharger le fichier docker-compose.yml et faire les modifications du fichier avec vos informations, puis : run ``docker-compose up -d``

## Configuration

### Ports exposées
- 8125 StatsD
- 8092 UDP
- 8094 TCP  


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

### Arguments pour docker compose (ARGS=xxxxxxxx)
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

L'environnement ARGS est présent dans le fichier telegraf.conf juste après la commande ``/usr/local/py/freebox-monit.py -``.

  Sélectionnez simplement les métriques souhaitées et ajoutez les lettres choisies à la variable ARGS= dans docker compose

## Sources
- https://www.nas-forum.com/forum/topic/66394-tuto-monitorer-sa-freebox-revolution/
- https://hub.docker.com/r/repobazireinformatique/freebox-telegraf
