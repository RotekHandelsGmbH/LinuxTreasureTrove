# rsync howto

- date : 2025-01-22

## rsync with numeric ids

```bash
sudo mkdir -p /destination/directory/
sudo rsync -aHAX --progress [--quiet] --numeric-ids /source/directory/ /destination/directory/
# -a: Archive mode; preserves symbolic links, permissions, timestamps, and more.
# -H: Preserves hard links.
# -A: Preserves Access Control Lists (ACLs).
# -X: Preserves extended attributes (xattrs).
# --quiet: no filelist (for logging in automated scripts)
# --progress: Displays a progress bar during synchronization.
# --numeric-ids: Transfers numeric user and group IDs to avoid mapping issues if the users/groups differ between systems.
# /source/directory/: The trailing slash ensures only the contents of the source directory are copied (not the directory itself).
# /destination/directory/: The target directory where files will be copied.
```

## rsync over ssh with compression, bandwith limit and append after connection brakes

```bash
# bandwith is in kBYTE/s (kBit/s / 8), so for 10MBit/s == 10.000kBit/s: bwlimit=1250 kByte/s 
# option z uses compression
rsync -avz \
    --partial \
    --append-verify \
    --bwlimit=1250 \ 
    --progress \
    /my/sourcedir/ \ 
    <user>@<hostname>2:/my/targetdir/
```

