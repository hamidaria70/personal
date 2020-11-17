## Quasar Maestro


### Overview

Quasar is a dockerized environment of the Maestro project.

### Specifications
The Quasar consists of at least 17 docker containers. Two of them are front-end, three of them are for cache, eleven of them are for back-end and the last one is a Nginx container as a gateway to handle requests.
The important thing is that we can use the swarm scaling feature to scale up or scale down quasar containers as simple as possible.

### 1. How to deploy a new version?

As we know a docker container will be born from a docker image and in the case of using swarm the important issue is the existence of docker images in the private registry, so all we need to do is a few steps and they are:

1. Build a new docker image 
2. Assign a new tag to it 

```bash
docker image build -t registry.xeba.tech/project_name:tag  .
```	

3. Push new image to the private registry

```bash
docker push registry.xeba.tech/project_name:tag
```	

4. Pull the new image from the private registry in the deployment environment

```bash
docker pull registry.xeba.tech/project_name:tag
```	

5. Edit the docker-compose.yml file and change the old image tag with the new one

```bash
vim /path/to/docker-compose.yml
```	

6. Update the stack by redeploying it

```bash
docker stack deploy -c /path/to/docker-compose.yml maestro
```	

7. Check the new version

```   
   TIP: For checking version you can use the curl command and call URL based on your deployment. In quasar there are three health API as below:
```

####dolphin

```bash
curl https://quasar.xeba.tech/apiv1/healths
```
####panda

```bash
curl https://quasar-cas.xeba.tech/apiv1/healths
```

####jaguar

```bash
curl https://quasar-jaguar.xeba.tech/apiv1/healths
```	
##djdedjghdjkhgdsh
###Swarm mode and add a new node to swarm
We may want to make our deployment environment bigger for any purpose. Here we can add another node to this swarm.
Like the previous, we need to run some very simple steps which are:
   2.1. First of all, we must initiate docker swarm mode by running this command in our deployment server or VM:

```bash
docker swarm init
```	

Swarm mode is  activated and to check the status of docker nodes by running:


doc:wker node ls
	

   9. All we need to do is to join the new node as a manager or worker to the first node or first deployment environment.


worker
	docker swarm join-token worker
	manager
	docker swarm join-token manage
	

After running these commands a command appears in the shell environment and you need to run that exactly in the newly created environment.
   10. To check the status of the node you can run the command below


docker node ls
	

TIP: notice that if you scale up containers or deploy a new stack, docker will decide which container should be running in which node.
TIP: you can add some configuration in docker-compose.yml to change docker decisions indeed.


3. How to scale up or down a service?


For scaling up or down a service we have 2 ways.
   11. Changing replica in the docker-compose.yml file and after that redeploy it
   12. Use this command below which is better and easier


docker service scale <service_name>=number
	For example:


docker service scale maestro_gateway=2
	        
You can check the changes from this command below:


docker service ls
	4. Administration guide
Here are some administration commands to check the containers and deployment environments:
   13. To check all of the containers use:


docker ps -a
	

   14. To check the list of services use:


docker service ls
	

   15. To check the status of containers in a stack


docker stack ps <serice_name>
	

   16. To check the status of running containers in a stack


docker stack ps -f "desired-state=running" <stack name>
	

   17. To check resource usage of containers 


docker stats
	

   18. To check the status of nodes


docker node ls
	

   19. To connect the container use


docker exec -it  <container name>  bash
