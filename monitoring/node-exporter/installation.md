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
cd node_exporter-0.17.0.linux-amd64/
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
sudo $EDITOR /etc/prometheus/prometheus.yml
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
