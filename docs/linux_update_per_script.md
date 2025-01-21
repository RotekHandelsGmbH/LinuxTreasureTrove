# linux update per script howto


```bash
apt-get update
# Configure any packages that were unpacked but not yet configured
dpkg --configure -a
# Attempt to fix broken dependencies and install missing packages
apt-get --fix-broken install -y -o Dpkg::Options::="--force-confold"
# Upgrade all installed packages while keeping existing configuration files
apt-get upgrade -y -o Dpkg::Options::="--force-confold"
# Perform a distribution upgrade, which can include installing or removing packages
# This also keeps existing configuration files
apt-get dist-upgrade -y -o Dpkg::Options::="--force-confold"
# Clean up the local repository of retrieved package files to free up space
apt-get autoclean -y
# Remove unnecessary packages and purge their configuration files
apt-get autoremove --purge -y
# Forcing Phased Updates : If the package is held back due to a phased update,
# this command will still upgrade the package immediately, bypassing the phased rollout restrictions.
# it will not mark it as manually installed
apt-get -s upgrade | grep "^Inst" | awk '{print $2}' | xargs -n 1 apt-get install --only-upgrade -y -o Dpkg::Options::="--force-confold"
# Repeat cleaning up of the package files after additional installations
apt-get autoclean -y
# Repeat removal of unnecessary packages after additional installations
apt-get autoremove --purge -y
```

## linux update with [lib_bash](https://github.com/bitranox/lib_bash) howto

```bash 
sudo /usr/local/lib_bash/lib_helpers.sh linux_update 
```

## linux update in a script with [lib_bash](https://github.com/bitranox/lib_bash) howto 

```bash 
source /usr/local/lib_bash/lib_helpers.sh
linux_update 
```
