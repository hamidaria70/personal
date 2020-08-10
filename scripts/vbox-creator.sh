#!/bin/bash

set -e

NAME=monitoring
OSTYPE=Debian_64
RAM_VALUE=1024
CPU_NUM=1
ADAPTER_NAME=enp3s0
HDD_VALUE=20480
PORT_NUM=1112
HDD_ADDR="/home/$USER/VirtualBox VMs/$NAME/$NAME.vdi"
ISO_ADDR=/home/hamid/Downloads/ubuntu-20.04.1-live-server-amd64.iso

VBoxManage createvm --name $NAME --ostype $OSTYPE --register
VBoxManage modifyvm $NAME --memory $RAM_VALUE --cpus $CPU_NUM

VBoxManage modifyvm $NAME --bridgeadapter1 $ADAPTER_NAME
VBoxManage modifyvm $NAME --nic1 bridged

VBoxManage createhd --filename "$HDD_ADDR" --size "$HDD_VALUE" --format VDI

VBoxManage storagectl $NAME --name "SATA Controller" --add sata \
	--controller IntelAhci

VBoxManage storageattach $NAME --storagectl "SATA Controller" \
	--port 0 --device 0 --type hdd --medium "$HDD_ADDR"

VBoxManage storagectl $NAME --name "IDE Controller" --add ide --controller PIIX4

VBoxManage storageattach $NAME --storagectl "IDE Controller" \
	--port 1 --device 0 --type dvddrive --medium "$ISO_ADDR"
VBoxManage modifyvm $NAME --vrde on
VBoxManage modifyvm $NAME --vrdemulticon on --vrdeport $PORT_NUM
VBoxManage startvm $NAME --type headless
