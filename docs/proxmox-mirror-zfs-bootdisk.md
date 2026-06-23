# Proxmox - Mirror the ZFS Boot disk

## ✅ Step1: Check the drive names
```bash
lsblk
# NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda      8:0    0 476.9G  0 disk 
# ├─sda1   8:1    0  1007K  0 part 
# ├─sda2   8:2    0     1G  0 part 
# └─sda3   8:3    0 475.9G  0 part 
# sdb      8:16   0 476.9G  0 disk 
# sdc      8:32   0   3.6T  0 disk 
# ├─sdc1   8:33   0   3.6T  0 part 
# └─sdc9   8:41   0     8M  0 part 
# zd0    230:0    0   128G  0 disk [SWAP]
```

`sda` is the source, `sdb`is the disk to mirror to

## ✅ Step2: Replicate the Partition Table
```bash
sgdisk --backup=/tmp/sda-layout.gpt /dev/sda
sgdisk --load-backup=/tmp/sda-layout.gpt /dev/sdb
```

## ✅ Step3: Set Partition GUIDs
ZFS prefers unique GUIDs per partition. You can randomize them for sdb:
```bash
sgdisk -G /dev/sdb
```

## ✅ Step4: Attach ZFS Partition (sdb3) to Mirror the Pool
```bash
# Find your ZFS pool name:
zpool status
#   pool: rpool
#  state: ONLINE
# config:
#
#         NAME        STATE     READ WRITE CKSUM
#         rpool       ONLINE       0     0     0
#           sda3      ONLINE       0     0     0
zpool attach rpool /dev/sda3 /dev/sdb3

# Check sync progress with:
zpool status
#   pool: rpool
#  state: ONLINE
# status: One or more devices is currently being resilvered.  The pool will
#         continue to function, possibly in a degraded state.
# action: Wait for the resilver to complete.
#   scan: resilver in progress since Sun Apr 27 20:52:05 2025
#         187G / 187G scanned, 11.9G / 187G issued at 437M/s
#         12.0G resilvered, 6.38% done, 00:06:50 to go
# config:
# 
#         NAME        STATE     READ WRITE CKSUM
#         rpool       ONLINE       0     0     0
#           mirror-0  ONLINE       0     0     0
#             sda3    ONLINE       0     0     0
#             sdb3    ONLINE       0     0     0  (resilvering)
# 
# errors: No known data errors


```

## ✅ Step5: transfer Bootloader (EFI) to the mirror
```bash
# Format EFI Partition (Proxmox way)
proxmox-boot-tool format /dev/sdb2 --force
# Initialize the Bootloader
proxmox-boot-tool init /dev/sdb2
# Sync Boot Partition
proxmox-boot-tool refresh
# double-check setup with:
proxmox-boot-tool status
# root@proxmox03:/rotek/scripts/adminscripts# proxmox-boot-tool status
# Re-executing '/usr/sbin/proxmox-boot-tool' in new private mount namespace..
# System currently booted with legacy bios
# 0B92-3E46 is configured with: grub (versions: 6.8.12-8-pve, 6.8.12-9-pve)
# 27BA-C186 is configured with: grub (versions: 6.8.12-8-pve, 6.8.12-9-pve)
# WARN: /dev/disk/by-uuid/C231-F88C does not exist - clean '/etc/kernel/proxmox-boot-uuids'! - skipping
proxmox-boot-tool clean
proxmox-boot-tool refresh
```
