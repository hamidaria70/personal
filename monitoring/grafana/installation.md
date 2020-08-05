## Grafana Installation

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

##### Add a Data Source

1. Click Add data source on the homepage.

2. Select Prometheus.

3. Set the URL to `http://localhost:9090`.

4. Click Save & Test.
