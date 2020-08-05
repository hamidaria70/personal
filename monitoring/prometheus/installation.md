## Prometheus Installation

Please follow and run commands below step by step.

1. Create a system user for Prometheus:

```sudo useradd --no-create-home --shell /bin/false prometheus```

2. Create the directories in which we'll be storing our configuration files and libraries:

```sudo mkdir /etc/prometheus```

```sudo mkdir /var/lib/prometheus```

3. 
