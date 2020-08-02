## Zabbix 3.4 installation on RedHat 7


### Compatibility table

| Zabbix version | OS version |
| ------- | ------ |
|zabbix-server 3.4.12 | Red Hat Enterprise Linux Server release 7.3 |


### Introduction

Zabbix was created by Alexei Vladishev, and currently is actively developed and
supported by Zabbix SIA.

Zabbix is an enterprise-class open source distributed monitoring solution.

Zabbix is software that monitors numerous parameters of a network and the
health and integrity of servers. Zabbix uses a flexible notification mechanism
that allows users to configure e-mail based alerts for virtually any event.
This allows a fast reaction to server problems. Zabbix offers excellent
reporting and data visualisation features based on the stored data. This makes
Zabbix ideal for capacity planning.

Zabbix supports both polling and trapping. All Zabbix reports and statistics,
as well as configuration parameters, are accessed through a web-based frontend.
A web-based frontend ensures that the status of your network and the health of
your servers can be assessed from any location. Properly configured, Zabbix can
play an important role in monitoring IT infrastructure. This is equally true
for small organisations with a few servers and for large companies with a
multitude of servers.

Reference: https://www.zabbix.com/documentation/3.4/manual/installation/install_from_packages/rhel_centos


### Prerequisites

Install the repository configuration package. This package contains yum
(software package manager) configuration files.
```bash
rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
```

Install `yum-utils` and `zabbix` package by following commands:

```bash
yum install -y yum-utils postgresql postgresql-server zabbix-server-pgsql zabbix-web-pgsql zabbix-agent
yum-config-manager --enable rhel-7-server-optional-rpms
yum -y update
```


### Postgresql

```bash
service postgresql initdb
systemctl enable postgresql
service postgresql start
```


#### Database and user

Create user and set password by following line:

```bash
echo 'CREATE USER zabbix' | sudo -u postgres psql
echo "ALTER USER zabbix WITH PASSWORD '<password>'" | sudo -u postgres psql
```

Create database for Zabbix:

```bash
echo "CREATE DATABASE zabbix OWNER zabbix" | sudo -u postgres psql
```

Edit `/var/lib/pgsql/data/pg_hba.conf` for connecting user to database with password:


#### Enable remote access of postgresql with MD5 algorithm

```bash
# IPv4 local connections:
host
all     all     127.0.0.1/32    md5
```


#### Importing data

Now import initial schema and data for the server with PostgreSQL

```bash
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix
```


### Configure the Zabbix

#### Database connection.

Edit `/etc/zabbix/zabbix_server.conf` to use the created database. For example:

```bash
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=<password>
```


#### Zabbix frontend configuration

Edit `/etc/httpd/conf.d/zabbix.conf` file and set php configuration:

```bash
php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value always_populate_raw_post_data -1
php_value date.timezone Asia/Tehran
```


### SELinux configuration

Having SELinux status enabled in enforcing mode, you need to execute the
following commands to enable communication between Zabbix frontend and server:

```bash
setsebool -P httpd_can_connect_zabbix on
setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_network_connect on
setsebool -P zabbix_can_network on
```

Set permission to zabbix_server for write and read on `/var/run/zabbix/`
directory by following line:

```bash
chcon -t zabbix_var_run_t /usr/sbin/zabbix_server
```

### Firewall configuration

Open the port `tcp/10050` & `tcp/80` on firewall

```bash
firewall-cmd --add-port=10050/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload
```


### Disable IPv6 in kernel module (requires reboot)

Edit `/etc/default/grub` and add `ipv6.disable=1` in line `GRUB_CMDLINE_LINUX`, e.g.:

```bash
GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rd.lvm.lv=cl/root rd.lvm.lv=cl/swap rhgb
quiet"
```
Regenerate a GRUB configuration file and overwrite existing one:

```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```
Restart system and verify no line “inet6” in “ip addr show” command output.

```bash
shutdown -r now
ip addr show | grep net6
```

### Time Zone

Set time zone Asia/Tehran
```bash
timedatectl set-timezone Asia/Tehran
```

### Start services

Start and enable all zabbix service

```bash
systemctl enable zabbix-server
systemctl enable zabbix-agent
systemctl enable httpd
service zabbix-agent start
service zabbix-server start
service httpd restart
service postgresql restart
```


### First time wizard

##### Step 1
In your browser, open Zabbix URL: http://<server_ip_or_name>/zabbix
You should see the first screen of the frontend installation wizard.

##### Step 2
Make sure that all software prerequisites are met.

##### Step 3
Enter details for connecting to the database. Zabbix database must already be
created.

##### Step 4
Enter Zabbix server details.

##### Step 5
Review a summary of settings.

##### Step 6
Finish the installation.

##### Step 8
Zabbix frontend is ready! The default user name is `Admin`, password `zabbix`


### Agent installation


#### Repository installation For Red Hat Enterprise Linux

Install the repository configuration package

```bash
rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
```

#### To install agent

```bash
yum install zabbix-agent
```


### Zabbix Agent Configuration

Edit zabbix agent configuration file `/etc/zabbix/zabbix_agentd.conf`

```bash
server=ip address of zabbix server
ServerActive=ip of zabbix server
Hostname=use the FQDN of the node where the agent runs
```

Open zabbix agent Port on firewall

```bash
firewall-cmd --add-port=10050/tcp --permanent
firewall-cmd --reload
```

Restart and enable Zabbix Agent

```bash
systemctl restart zabbix-agent
systemctl enable zabbix-agent
```


#### Add Zabbix Agent Monitored Host to Zabbix Server

On the next step it’s time to move to Zabbix server web console and start
adding the hosts which run zabbix agent in order to be monitored by the server.
Go to `Configuration -> Hosts -> Create Host -> Host` tab and fill the Host name field with
the FQDN of the monitored zabbix agent machine, use the same value as above
for Visible name field


#### Monitoring nginx logs

* 1.Add a template to new hosts in order to get availability in web console.

* 2.Create new items with the followig values:

```bash
Name: Your choice
Type: zabbix agent(active)
Key: log.count[/var/log/nginx/access.log,"---"]
Update interval: 5s
```

* 3.Create a graph with newly created items.

* 4.Add `zabbix` user to `adm` group in agent machine.

* 5.Add the graph to your dasboard. Now the graph shows the nginx log.

