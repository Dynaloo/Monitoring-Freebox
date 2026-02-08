# MONITORING FREEBOX (In PROXMOX LXC Container)

**INSTALL INFLUXDB_V2:**

***Firstly:***

Install Debian 12 in a Proxmox (create new LXC container).

	hostname : influxdb_v2
	Memory : 512 MIB
	Swap : 512 MIB
	Core : 1
	Unprivileged container : yes (par defaut)
	nesting : yes (par defaut)
	disk size : 8 GB

Then, connect via SSH as root.

Update Debian:

	apt-get update & apt-get upgrade -y

Install Curl (which is not installed by default in Debian)

	apt install curl

***secondly:***

Install influxdb_v2

	curl --silent --location -O \
	https://repos.influxdata.com/influxdata-archive.key
	echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
	| sha256sum --check - && cat influxdata-archive.key \
	| gpg --dearmor \
	| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
	&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
	| tee /etc/apt/sources.list.d/influxdata.list

Install InfluxDB_V2

	apt-get update && apt-get install influxdb2

Start of services

	systemctl start influxdb
	
Persistence at startup

	systemctl enable influxdb
	
Status check

	systemctl status influxdb
	

Login: https://ip_influxdb_v2:8086

Complete the form on the first launch
	
- Enter Username  #for your initial user

- Enter Password and Confirm Password  #for your user.

- Enter your initial Organization Name  #par ex.: monitoring

- Enter your initial Bucket Name  #par ex.: freebox

Click Continue.

- Copy the provided admin API token and store it securely.

  Or,
  
- Create and copy a specific token for the "freebox" bucket.

- Remember to adjust the retention period (e.g., 3 days for the Freebox bucket)

**INSTALL GRAFANA:**

***Firstly:***

Install Debian 12 in a Proxmox (create new LXC container).

	hostname : grafana
	Memory : 512 MIB
	Swap : 512 MIB
	Core : 1
	Unprivileged container : yes (par defaut)
	nesting : yes (par defaut)
	disk size : 8 GB

Then, connect via SSH as root.

Update Debian:

	apt-get update & apt-get upgrade -y
  
Install the prerequisite packages

	apt-get install -y apt-transport-https software-properties-common wget
	
Import the GPG key

	mkdir -p /etc/apt/keyrings/
	
	wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
	
add a repository for stable versions

	echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
	
add a repository for beta versions

	echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | tee -a /etc/apt/sources.list.d/grafana.list
	
update the list of available packages

	apt-get update
	
Install Grafana OSS

	apt-get install grafana
	
Or, for businesses, if you have subscribed,

	apt-get install grafana-enterprise

Start of services

	systemctl daemon-reload
	systemctl start grafana-server
	
Persistence at startup

	systemctl enable grafana-server.service
	
Status check

	systemctl status grafana-server

Then connect: http://ip_grafana:3000

- Id : **admin** # by default on first launch

- Pw : **admin** # by default on first launch

**INSTALL TELEGRAF:**

***Firstly:***

Install Debian 12 in a Proxmox (create new LXC container).

  	hostname : telegraf
	Memory : 512 MIB
	Swap : 512 MIB
	Core : 1
	Unprivileged container : yes (par defaut)
	nesting : yes (par defaut)
	disk size : 8 GB

Then, connect via SSH as root.

Update Debian:

	apt-get update && apt-get upgrade -y

Check your Python version (Python is normally installed with Debian)

	python3 --version
	
If Python is not installed

	apt install python3
	
Next, install Pip3

	apt update && apt install python3-pip -y
	
Check the Pip3 version

	pip3 --version
	
Then install requests and unidecode

	pip install requests --break-system-packages
	pip install unidecode --break-system-packages
	
List all installed Python packages

	pip list
	
Create the 'py' directory

    mkdir /usr/local/py
	
Install Curl (which is not installed by default in Debian)

	apt install curl
	
Next, install Telegraf.

	curl --silent --location -O \
	https://repos.influxdata.com/influxdata-archive.key \
	&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
	| sha256sum -c - && cat influxdata-archive.key \
	| gpg --dearmor \
	| tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
	&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
	| tee /etc/apt/sources.list.d/influxdata.list

	apt-get update && apt-get install telegraf

**Configuration:**

***Récupération du script:***

- Copy the 'telegraf.conf' file to the /etc/telegraf/ directory (using filezila or winscp)
	
- Copy the contents of the 'telegraf.d' directory to the /etc/telegraf/telegraf.d/ directory (using filezila or winscp)
	
- Copy the 'freebox.py' file to the /usr/local/py/ directory (using filezila or winscp)


Go to directory:

	cd /usr/local/py

Change the file permissions

	chown root:root freebox.py && chmod 777 freebox.py


***Modify Telegraf file:***
	
	Edit the file /etc/telegraf/telegraf.d/freebox.conf and modify the red zone

{\color{red}Bienvenue}
$\color{green}{test}$

[[outputs.influxdb_v2]]
  urls = ["http://$\color{red}{Your_IP_InfluxDB2}$:8086"]
  
  token = "Your_Token_InfluxDB2"
  
  organization = "Organization_Name_in_your_InfluxDB2"
  
  bucket = "freebox" # Bucket_name_created_in_your_InfluxDB2 - Why not "freebox"

  commands = [
    "python3 /usr/local/py/freebox_061.py -SPHDIWXYZ4" # Or "freebox_070.py" which is latest version
]

- systemctl start telegraf  # to start Telegraf
- systemctl enable telegraf  # to make it persistent on restart
- systemctl restart telegraf  # to restart Telegraf
    
- systemctl stop telegraf  # to stop Telegraf

Start recording from the Freebox:

python3 freebox.py -r  (Here, you will need to validate the API on the box.)
                   -h  (to see the options)
                   -s  (to see the status)
