# ocamlfuse

- date : 2025-01-22

## install ocamlfuse

see [Installation](https://github.com/astrada/google-drive-ocamlfuse/wiki/Installation)

```bash
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse
```

## create a new google cloud project (or check each and every point on your existing project)

- go to [Google Cloud](https://console.cloud.google.com) and create a new project
- open Your project
- go to [Google Cloud API](https://console.cloud.google.com/apis/dashboard) and activate the `Google Drive API`
- go to [Credentials](https://console.cloud.google.com/apis/credentials) and add OAuth 2.0-Client-IDs
  - Application Type: Desktop App → Name it (e.g., Drive-FUSE-Client).
  - it is possible (and recommend for some cases) to use a `Service Account`, but in that case You need to share every
    directory seperately in the GDrive - I want to share my whole drive on the linux machine, so i did not use that. 
  - note down the name (the name You have given)
  - note the Client ID: `************-*******************************.apps.googleusercontent.com`
  - note the secret(key): `******-****************************`
  - go to [OAuth.Consent](https://console.cloud.google.com/apis/credentials/consent)
    - leave the APP in Test Mode
    - add Your Google Account `yourusername@gmail.com` as a test user - **otherwise the key will expire after 7 days**

## install the key on the linux machine

### with graphical interface and browser installed

```bash
rm -rf ~/.gdfuse/default  # this is crucial
google-drive-ocamlfuse \
  -id "YOUR_CLIENT_ID" \
  -secret "YOUR_CLIENT_SECRET"
# Follow the OAuth flow
```

### on Headless Machines

```bash
rm -rf ~/.gdfuse/default  # this is crucial
google-drive-ocamlfuse -headless \
  -id "YOUR_CLIENT_ID" \
  -secret "YOUR_CLIENT_SECRET"
# Follow the OAuth flow
```

## TEST

```bash
mkdir -p ~/GoogleDrive
# show debug messages, trace screen output
google-drive-ocamlfuse -d -o allow_other ~/GoogleDrive # for minimal debug output 
# show more debug messages, trace the logfile
google-drive-ocamlfuse -debug -o allow_other /home/srvadmin/GoogleDrive
# '-d': show debug in the screen and keeps it in foreground even on errors, check carefully for errors
# '-debug': will show more and better debug in logfile and keeps it in foreground even on errors, check carefully for errors
# '-f': keep google-drive-ocamlfuse in foreground 
# '-o allow_other': will allow other users (even root will not be allowed if not set) to access the drive
# in my case the log shows some errors, because ocamlfuse tried to stat `autorun.inf' which does not exist on my GoogleDrive
# if not put in -d, -debug or -f, ocamlfuse just exits in that case and does not work, just because of a missing file or directory 
# you should now be able to access the Google Drive
```

## make it permanent 

### create the file /usr/bin/gdfuse 

```conf
#!/bin/bash
# /usr/bin/gdfuse
# original : 
# su $USERNAME -l -c "google-drive-ocamlfuse -label $1 $*"
# However, google-drive-ocamlfuse expects in my case the file autorun.inf
# on Google Drive - if it does not exist, google-drive-ocamlfuse simply stops.
# so we keep it in foreground and redirect the output to >/dev/null
# and send the task to the background with "&".
su $USERNAME -l -c "google-drive-ocamlfuse -f -label $1 $*"  > /dev/null 2>&1 &
exit 0
```
```bash
sudo chmod +x /usr/bin/gdfuse
```

### add one line in fstab

```conf
gdfuse#default  /home/<username>/GoogleDrive     fuse    uid=1000,gid=1000,allow_other,user,_netdev     0       0
```

### mount the drive automatically on boot

```bash
sudo systemctl daemon-reload
sudo mount -a
```
