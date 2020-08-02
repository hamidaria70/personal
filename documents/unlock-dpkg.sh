#!/bin/bash

# Make sure that you have sudo access...

sudo killall apt apt-get dpkg
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a
sudo apt-get update
