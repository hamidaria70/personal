## The Difference between COPY and ADD in a Dockerfile

Sometimes you see COPY or ADD being used in a Dockerfile, but 99% of the time you should be using COPY, here's why.
COPY and ADD are both Dockerfile instructions that serve similar purposes. They let you copy files from a specific location into a Docker image.

COPY takes in a src and destination. It only lets you copy in a local file or directory from your host (the machine building the Docker image) into the Docker image itself.

ADD lets you do that too, but it also supports 2 other sources. First, you can use a URL instead of a local file / directory. Secondly, you can extract a tar file from the source directly into the destination.

In most cases if you’re using a URL, you’re downloading a zip file and are then using the RUN command to extract it. However, you might as well just use RUN with curl instead of ADD here so you chain everything into 1 RUN command to make a smaller Docker image.

A valid use case for ADD is when you want to extract a local tar file into a specific directory in your Docker image. This is exactly what the Alpine image does with ADD rootfs.tar.gz /.

If you’re copying in local files to your Docker image, always use COPY because it’s more explicit.
