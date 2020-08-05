## Alertmanager Installation

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
tar -xvf alertmanager-0.20.0.linux-amd64.tar.gz
```

5. Move the binaries:

```bash
cd alertmanager-0.20.0.linux-amd64
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
sudo $EDITOR /etc/systemd/system/alertmanager.service
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
sudo $EDITOR /etc/prometheus/prometheus.yml
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
