## Maestro Deployment on Docker swarm

### A Docker Version Deployment

#### 1. What do we need to deploy maestro in docker?

There are some elements we need to deploy maestro in docker which are:

* A host with a normal hardware configuration based on our needs with docker and docker compose

* Access to docker registry to pull docker images

* Cloned maestro repository from git

#### 2. Deployment for develop and production

As you can see in maestro project’s root there is a yaml file called docker-compose.yml. By using this file we can create all containers that need to run to get a maestro project up.but here is a thing that the way of deployment for production environment and development are a bit different.

* For development we should use docker-compose (Use Dockerize Maestro Tutorials)

* For production we should use docker swarm

Both environments have some features such as scaling services but the main reason for using swarm for production is that if container failure happens , swarm can handle it and makes a new container instead of a dead container.

#### 3. How to run Maestro on docker swarm?

It is very simple. we only need to run just one command inside the maestro project directory, which is:

```bash
docker stack deploy -c docker-compose.yml maestro
```

IT IS DONE.

But we have to wait for some moments for all containers be up.we can check the status of containers we use the command below:

```bash
Watch -n 1 docker service ls
```

Now we can call quasar.xeba.tech in the browser and check it.

#### 4. Cron jobs

There are three scripts that we need to copy them from the maestro cloned repository to /usr/local/bin with owner execute permission.

* nonworking  days script:

```bash
#!/bin/bash

CONTAINER=$(docker ps | grep dolphin-backend | rev | cut -d " " -f 1 | rev | head -1)
docker exec -it $CONTAINER dolphin -c deploy/dolphin.yml nonworking-days start
```

* timecard and check item mojo script:

```bash
#!/bin/bash

CONTAINER=$(docker ps | grep dolphin-backend | rev | cut -d " " -f 1 | rev | head -1)
docker exec -it $CONTAINER dolphin -c deploy/dolphin.yml check-item-mojo
docker exec -it $CONTAINER dolphin -c deploy/dolphin.yml timecard generate
```

With root user and crontab -e we can define cron jobs as below:

```bash
0 0 * * * timecard-mojo.sh
0 0 * */3 * nonworking-days.sh
```

#### 5. Changing port
In case of changing ports you can change your gateway (Nginx) configuration to listen to your designated port for example 80 or if you have a ssl certificate nginx will listen on 80 and 443.

But you need to configure docker to send the requests to designated ports you have chosen.in this case we just need to change the ports section in docker-compose.yml in gateway service like this or any ports we want:

```bash
Gateway:
  ...
  Ports:
    80:80
    443:443
```

#### 6. Scaling

For scaling up or down a service we have 2 ways.

1. Changing replica in docker-compose.yml file and after that redeploy it

2. Use this command below which is better and easier

```bash
Docker service scale <service_name>=number
```

For example:

```bash
Docker service scale maestro_gateway=2
```

You can check the changes from this command below:

```bash
Docker service ls
```
