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
