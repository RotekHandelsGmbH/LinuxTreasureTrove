# LinuxTreasureTrove
Linux treasure trove, various Ubuntu/Debian snippets for rediscovery

- [amdgpu settings ubuntu mint mate](./docs/amdgpu_settings_ubuntu_mint_mate.md)
- [rsync howto](./docs/rsync.md) 
- [send email logs on crontab errors](./docs/send_email_logs_on_crontab_errors.md)
- [synchronize imap servers and mailboxes](./docs/synchronize_imap_servers_and_mailboxes.md)


# reinstall packages without changing their marking (manual/auto installed)
```bash
packages="pkg1 pkg2 pkg2"
for pkg in ${packages}; \
  do apt-mark showmanual | \
    grep -q "^${pkg}$" && \
    (sudo apt-get install --reinstall -o Dpkg::Options::="--force-confold" -y ${pkg} && sudo apt-mark manual ${pkg}) || \
    (sudo apt-get install --reinstall -o Dpkg::Options::="--force-confold" -y ${pkg} && sudo apt-mark auto ${pkg}); \
  done
```
