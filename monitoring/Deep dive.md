# DevOps Monitoring Deep Dive

## Content:

1. [Introduction](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#1-introduction)
2. [Prometheus Setup](https://github.com/hamidaria70/personal/blob/master/monitoring/Deep%20dive.md#2-prometheus-setu)
3. Node Exporter Installation & Configuration
4. Grafana Installation & Configuration
5. Alert Manager Installation & Configuration
6. Postfix Mail Server Installation & Configuration
7. Writing Query

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

### 4. Grafana Installation & Configuration

### 5. Alert Manager Installation & Configuration

### 6. Postfix Mail Server Installation & Configuration

### 7. Writing Query 
