##------- telegraf:1.29.2 non testé -------##

#FROM telegraf:1.29.2
FROM telegraf:1.31.2

# Install required packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    python3-distutils \
    python3-pip \
    python3-full

# Installation module necessaire pour le script python
RUN pip3 install requests --break-system-packages \
    && pip3 install unidecode --break-system-packages \
    && rm /entrypoint.sh


ADD --chmod=1755 entrypoint.sh /
ADD freebox-monit.py /usr/local/py/
ADD telegraf.conf /etc/telegraf/

ENTRYPOINT ["/entrypoint.sh"]