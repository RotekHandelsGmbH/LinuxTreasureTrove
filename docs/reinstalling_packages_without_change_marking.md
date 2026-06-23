# reinstall packages without changing their marking (manual/auto installed) howto

- date : 2025-01-22

The auto/manual marking helps maintain a clean and efficient system by ensuring unused dependencies are automatically cleaned up.
It prevents accidental removal of packages that the user explicitly wanted to keep.
if You just reinstall a package with `apt-get reinstall` or `apt-get install --reinstall` it is marked as "manual", so it will not be cleaned up on `apt-get 
autoremove` anymore  

```bash
packages="pkg1 pkg2 pkg2"
for pkg in ${packages}; \
  do apt-mark showmanual | \
    grep -q "^${pkg}$" && \
    (sudo apt-get install --reinstall -o Dpkg::Options::="--force-confold" -y ${pkg} && sudo apt-mark manual ${pkg}) || \
    (sudo apt-get install --reinstall -o Dpkg::Options::="--force-confold" -y ${pkg} && sudo apt-mark auto ${pkg}); \
  done
```

## reinstall packages without changing their marking with [lib_bash](https://github.com/bitranox/lib_bash) howto

```bash 
sudo /usr/local/lib_bash/lib_helpers.sh reinstall_keep_marking "pkg1 pkg2 pkg2" 
```

## reinstall packages without changing their marking in a script with [lib_bash](https://github.com/bitranox/lib_bash) howto 

```bash 
source /usr/local/lib_bash/lib_helpers.sh
reinstall_keep_marking "pkg1 pkg2 pkg2" 
```
