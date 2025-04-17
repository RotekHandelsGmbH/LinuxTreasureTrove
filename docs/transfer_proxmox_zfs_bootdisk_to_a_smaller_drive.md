# Step-by-Step Guide to transfer a Proxmox ZFS Bootdisk to Smaller Disk)
we assume here the old drive is /sda, the new drive is /sdc - adjust as needed
with this method host-id and cluster menbership remain the same

## check again how Your system is booting
```bash
[ -d /sys/firmware/efi ] && echo "UEFI boot" || echo "BIOS boot"
```

## install proxmox on the new disk, with the same boot method
use zfs also on the new installation, do not worry about any settings since rpool will be replaced.

## Boot into a Live Environment with ZFS Support
boot from Ubuntu Live ISO + zfsutils-linux

## Import and rename the Original ZFS Pool
```bash
# import the rpool from 3
# mount and rename rpool to oldrpool
zpool import -f rpool oldrpool -R /mnt/oldrpool
```

## Import and delete the new rpool
```bash
# import the rpool from the new disk
zpool import
zpool import -f rpool -R /mnt/newrpool
# delete the new rpool
zpool destroy rpool
```

## Create a new, empty rpool on /dev/sdc3
```bash
zpool create -f \
  -o ashift=12 \
  -o autotrim=on \
  -O compression=lz4 \
  -O atime=off \
  -O mountpoint=/rpool \
  -R /mnt/newrpool \
  rpool-new /dev/sdc3   # select correct partition here
```

## Snapshot the oldrpool
```bash
zfs list -r oldrpool 
zfs snapshot -r oldrpool/ROOT@transfer
zfs snapshot -r oldrpool/data@transfer
zfs snapshot -r oldrpool/var-lib-vz@transfer
# ... make that for all Pools
```

## Send the Snapshot to the New rpool
```bash
zfs send -R oldrpool/ROOT@transfer | zfs receive -F newrpool/ROOT
zfs send -R oldrpool/data@transfer | zfs receive -F newrpool/data
zfs send -R oldrpool/var-lib-vz@transfer | zfs receive -F newrpool/var-lib-vz
# ... make that for all Pools
```
## delete all snapshots
```bash
zfs list -H -o name -t snapshot -r rpool | xargs -n1 zfs destroy
```

## boot from the new disk
on the first boot You will have to import rpool manually :
```bash
zpool import rpool -f
exit
```
