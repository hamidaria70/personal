# DevOps Monitoring Deep Dive

## Content:

1. [Introduction](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#1-introduction)
2. [Prometheus Setup](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#2-prometheus-setup)
3. [Node Exporter Installation & Configuration](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#3-node-exporter-installation--configuration)
4. [Grafana Installation & Configuration](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#4-grafana-installation--configuration)
5. [Alert Manager Installation & Configuration](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#5-alert-manager-installation--configuration)
6. [Postfix Mail Server Installation & Configuration](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#6-postfix-mail-server-installation--configuration)
7. [Writing Query](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#6-postfix-mail-server-installation--configuration)

***

### 1. Introduction

Welcome to the DevOps Monitoring Deep Dive!. We’ll be using a widespread monitoring stack to learn the concepts behind setting up successful monitoring: From considering whether to use a pull or push solution, to understanding the various metric types, to thinking scale, we'll be taking a look at monitoring on the infrastructure, as well as how we can best use the metrics we're monitoring for to gain insight into our system and make data-driven decisions.

***

### 2. Prometheus Setup

Now that we have what we're monitoring set up, we need to get our monitoring tool itself up and running, complete with a service file. Prometheus is a pull-based monitoring system that scrapes various metrics set up across our system and stores them in a time-series database, where we can use a web UI and the PromQL language to view trends in our data. Prometheus provides its own web UI, but we'll also be pairing it with Grafana later, as well as an alerting system.

Please follow and run commands below step by step.

1. Create a system user for Prometheus:

```bash
sudo useradd --no-create-home --shell /bin/false prometheus
```

2. Create the directories in which we'll be storing our configuration files and libraries:

```bash
sudo mkdir /etc/prometheus
```

```bash
sudo mkdir /var/lib/prometheus
```

3. Set the ownership of the `/var/lib/prometheus` directory:

```bash
sudo chown prometheus:prometheus /var/lib/prometheus
```

4. Pull down the `tar.gz` file from the [Prometheus downloads page](https://prometheus.io/download/):

```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.20.0/prometheus-2.20.0.linux-amd64.tar.gz
```

5. Extract the files:

```bash
 tar -xvf prometheus-2.20.0.linux-amd64.tar.gz
```

6. Move the configuration file and set the owner to the `prometheus` user:

```bash
cd prometheus-2.20.0.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
```

7. Move the binaries and set the owner:

```bash
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```
8. Create the service file:

```bash
sudo vim /etc/system/system/promethues.service
Add:

```bash
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```
Save and exit. (For VIM, press 'ESC, :, wq' to save and exit.)

9. Reload systemd:

```bash
sudo systemctl daemon-reload
```

10. Start Prometheus, and make sure it automatically starts on boot:

```bash
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

11. Visit Prometheus in your web browser at `localhost:9090`.

***

### 3. Node Exporter Installation & Configuration

Right now, our monitoring system only monitors itself; which, while beneficial, is not the most helpful when it comes to maintaining and monitoring all our systems as a whole. We instead have to add endpoints that will allow Prometheus to scrape data for our application, container, and infrastructure.

1. Create a system user:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
```

2. Download the `Node Exporter` from [Prometheus's download page](https://prometheus.io/download/#alertmanager):

```bash
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
```

3. Extract its contents; note that the versioning of the Node Exporter may be different:

```bash
tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz
```

4. Move into the newly created directory:

```bash
cd node_exporter-1.0.1.linux-amd64/
```

5. Move the provided binary:

```bash
sudo mv node_exporter /usr/local/bin/
```

6. Set the ownership:

```bash
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

7. Create a systemd service file:

```bash
sudo vim /etc/systemd/system/node_exporter.service
```

```bash
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

Save and exit when done.

8. Start the Node Exporter:

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
```

9. Add the endpoint to the Prometheus configuration file:

```bash
sudo vim /etc/prometheus/prometheus.yml
```

```bash
- job_name: 'nodeexporter'
  static_configs:
  - targets: ['localhost:9100']
```

10. Restart Prometheus:

```bash
sudo systemctl restart prometheus
```

11. Navigate to the Prometheus web UI. Using the expression editor, search for `cpu`, `meminfo`, and related system terms to view the newly added metrics.

12. Search for `node_memory_MemFree_bytes` in the expression editor; shorten the time span for the graph to be about 30 minutes of data.

13. Back on the terminal, download and run `stress` to cause some memory spikes:

```bash
sudo apt-get install stress
stress -m 2
```

14. Wait for about one minute, and then view the graph to see the difference in activity.

***

### 4. Grafana Installation & Configuration

While Prometheus provides us with a web UI to view our metrics and craft charts, the web UI alone is often not the best solution to visualizing our data. Grafana is a robust visualization platform that will allow us to see trends in our metrics better and give us insight into what's going on with our applications and servers. It also lets us use multiple data sources, not just Prometheus, which provides us with a full view of what's happening.

#### 4.1. Grafana Installation

Please follow and run commands below step by step:

1. Install the prerequisite package:

```bash
sudo apt-get install libfontconfig
```

2. Download and install Grafana using the `.deb` package provided on the [Grafana download page](https://grafana.com/grafana/download):

```bash
wget https://dl.grafana.com/oss/release/grafana_7.1.1_amd64.deb
sudo dpkg -i grafana_7.1.1_amd64.deb
```

3. Ensure Grafana starts at boot:

```bash
sudo systemctl enable --now grafana-server
```

4. Access Grafana's web UI by going to `localhost:3000`.

5. Log in with the username `admin` and the password `admin`. Reset the password when prompted.

#### 4.2. Add a Data Source

1. Click Add data source on the homepage.

2. Select Prometheus.

3. Set the URL to `http://localhost:9090`.

4. Click Save & Test.

***

### 5. Alert Manager Installation & Configuration

Monitoring is never just monitoring. Ideally, we'll be recording all these metrics and looking for trends so we can better react when things go wrong and make smart decisions. And once we have an idea of what we need to look for when things go wrong, we need to make sure we know about it. This is where alerting applications like Prometheus's standalone Alertmanager come in.

Please follow and run commands below step by step:

1. Create the `alertmanager` system user:

```bash
sudo useradd --no-create-home --shell /bin/false alertmanager
```

2. Create the `/etc/alertmanager` directory:

```bash
sudo mkdir /etc/alertmanager
```

3. Download Alertmanager from the [Prometheus downloads page](https://prometheus.io/download/#alertmanager):

```bash
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
```

4. Extract the files:

```bash
tar -xvf alertmanager-0.21.0.linux-amd64.tar.gz
```

5. Move the binaries:

```bash
cd alertmanager-0.21.0.linux-amd64
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/
```

6. Set the ownership of the binaries:

```bash
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
```

7. Move the configuration file into the `/etc/alertmanager` directory:

```bash
sudo mv alertmanager.yml /etc/alertmanager/
```

8. Set the ownership of the `/etc/alertmanager` directory:

```bash
sudo chown -R alertmanager:alertmanager /etc/alertmanager/
```

9. Create the `alertmanager.service` file for systemd:

```bash
sudo vim /etc/systemd/system/alertmanager.service
```

Copy and Paste content:

```bash
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml
[Install]
WantedBy=multi-user.target
```

Save and exit.

10. Stop Prometheus, and then update the Prometheus configuration file to use Alertmanager:

```bash
sudo systemctl stop prometheus
sudo vim /etc/prometheus/prometheus.yml
```

```bash
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
```

11. Reload systemd, and then start the `prometheus` and `alertmanager` services:

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl start alertmanager
```

12. Make sure `alertmanager` starts on boot:

```bash
sudo systemctl enable alertmanager
```

13. Visit `localhost:9093` in your browser to confirm Alertmanager is working.

***

### 6. Postfix Mail Server Installation & Configuration

Postfix is a mail transfer agent (MTA), an application used to send and receive
email. In this tutorial, we will install and configure Postfix so that it can
be used to send emails by local applications only.

Please follow and run commands below step by step:

1. First, update the package database:

```bash
sudo apt-get update
```

2. Finally, install Postfix. Installing mailtuils will install Postfix as well as a few other programs needed for Postfix to function.

```bash
sudo apt install mailutils
```

3. Near the end of the installation process, you will be presented with a window that looks exactly like the one in the image below. The default option is Internet Site. That’s the recommended option for this tutorial, so press TAB, then ENTER.

[!zJuFrgI.png?1](zJuFrgI.png?1)

4. After that, you’ll get another window just like the one in the next image. The System mail name should be the same as the name you assigned to the server when you were creating it. If it shows a subdomain like subdomain.example.com, change it to just example.com. When you’ve finished, press TAB, then ENTER.

[!sVEi9SW.png?1](sVEi9SW.png?1)

















### 7. Writing Query 
