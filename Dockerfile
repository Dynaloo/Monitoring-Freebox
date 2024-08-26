##------- Choisir la version et supprimer celle non utilisée -------##

##------- telegraf:1.27.1 testé OK -------##

FROM telegraf:1.27.1

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
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py --prefix=/usr/local \
    && python3 -m pip install requests \
    && pip install unidecode \
    && rm /entrypoint.sh

#ADD entrypoint.sh /
ADD --chmod=1755 entrypoint.sh /
ADD freebox-monit.py /usr/local/py/
ADD telegraf.conf /etc/telegraf/

ENTRYPOINT ["/entrypoint.sh"]

##------- telegraf:1.29.2 non testé -------##

#FROM telegraf:1.29.2
#FROM telegraf:1.31.2

# Install required packages
#RUN apt-get update \
#    && apt-get upgrade -y \
#    && apt-get install -y --no-install-recommends \
#    apt-transport-https \
#    ca-certificates \
#    curl \
#    gnupg-agent \
#    software-properties-common \
#    python3-distutils \
#    python3-pip \
#    python3-full

# Installation module necessaire pour le script python
#RUN pip3 install requests --break-system-packages \
#    && pip3 install unidecode --break-system-packages \
#    && rm /entrypoint.sh


#ADD --chmod=1755 entrypoint.sh /
#ADD freebox-monit.py /usr/local/py/
#ADD telegraf.conf /etc/telegraf/

#ENTRYPOINT ["/entrypoint.sh"]