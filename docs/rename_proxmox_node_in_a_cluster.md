# rename a proxmox node in a proxmox cluster

## backup all images, containers and virtual machines - since You can rejoin the cluster only with a empty node without any of those !

```bash

# check cluster status
pvecm status

# delete the node from another node in the cluster
pvecm delnode <old-node-name>

# stop the cluster service on the deleted node
systemctl stop pve-cluster corosync

# at that moment the web interface on the deleted node does not work anymore
# login with ssh on the deleted node

ssh root@<old-node-ip>
hostnamectl set-hostname <new-node-name>

# change the host file on the renamed machine from <old-node-name> to <new-node-name> : 
sudo sed -i 's/<old-node-name>/<new-node-name>/g' /etc/hosts
sudo sed -i 's/<old-node-name>/<new-node-name>/g' /etc/hostname
systemctl stop pve-cluster corosync
rm -rf /etc/corosync/*
rm -rf /var/lib/pve-cluster/*
reboot
# then you can re-join the cluster as usual

```

