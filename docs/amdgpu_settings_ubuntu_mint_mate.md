# AMD GPU Settings for lightdm/ubuntu-mint-mate howto

- date : 2025-01-22

## Get Settings

### get the PCIe Slot

```bash
# The command "lspci -k | grep -EA3 'VGA|3D|Display'" identifies graphics-related devices (VGA, 3D, or Display controllers).
# It shows the PCI devices along with loaded kernel drivers and modules for these components.
# Useful for troubleshooting graphics issues or verifying the correct driver is loaded.
lspci -k | grep -EA3 'VGA|3D|Display'
> 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Tahiti XT [Radeon HD 7970/8970 OEM / R9 280X]
>	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Tahiti XT2 [Radeon HD 7970 GHz Edition]
>	Kernel driver in use: amdgpu
>	Kernel modules: radeon, amdgpu
# Note down the PCIE Slot used
```

### check DRM LOGs
```
sudo journalctl -xe -u drm -n10
sudo dmesg | grep -i drm
dmesg | grep -i drm
```

### check display manager log (in that case lightdm) for problems
```bash
sudo journalctl -xe -u lightdm --since "10 minutes ago"
cat /var/log/lightdm/lightdm.log
```

### check XORG LOG for errors
`cat ~/.local/share/xorg/Xorg.0.log | grep EE`

## Set Configs

### edit grub cfg in order to force load the amdgpu driver 

```bash
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT
# check following options are present, put the correct PCIe Slot 
# /etc/default/grub:
#> GRUB_CMDLINE_LINUX_DEFAULT="[...] [...] [...] systemd.unit=graphical.target radeon.si_support=0 amdgpu.si_support=1 drm.primary=PCI:0000:01:00.0"

# - "systemd.unit=graphical.target": parameter is used to configure the system to boot directly into the graphical user interface (GUI).
# It sets the systemd target to "graphical.target," which starts all necessary services for a graphical session.
# This can be added as a kernel boot parameter or used in system configuration for GUI-based environments.

# - "systemd.unit=multi-user.target": parameter configures the system to boot into a non-graphical, multi-user mode.
# It sets the systemd target to "multi-user.target," which starts network services and allows multiple users but does not load a GUI.
# This is commonly used for server environments or troubleshooting without a graphical interface.

# - "radeon.si_support=0": Disables support for Southern Islands (SI) GPUs in the Radeon driver.
# - "amdgpu.si_support=1": Enables support for Southern Islands (SI) GPUs in the AMDGPU driver.
# - "drm.primary=PCI:0000:01:00.0": Specifies the primary GPU device by its PCI address.
# These settings are useful for optimizing GPU usage, especially when switching between Radeon and AMDGPU drivers.
```

```bash
sudo update-grub
sudo initramfs -u
sudo reboot now
```

## if X is not coming up : 

### check correct driver is loaded
```bash
lspci -k | grep -EA3 'VGA|3D|Display'
> 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Tahiti XT [Radeon HD 7970/8970 OEM / R9 280X]
>	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Tahiti XT2 [Radeon HD 7970 GHz Edition]
>	Kernel driver in use: amdgpu    # <--------------------   amdgpu must be in use !
>	Kernel modules: radeon, amdgpu
```

### check lightdm config
```bash
sudo dpkg -l | grep greeter
sudo apt reinstall lightdm-gtk-greeter
sudo apt reinstall slick-greeter
nano /etc/lightdm.config
```

```conf
# set for debugging, comment out for production
# Provides detailed logs, including events, errors, and system interactions, which are helpful for diagnosing issues with the display manager.
# [LightDM]:
# log-level=debug                             # Sets the logging verbosity to "debug."

[Seat:*]

# specifies the virtual terminal (VT) on which the graphical session should star
# vt=7                                      # not neccessary

autologin-user=<user1000>                   # <----- put here the main system user (UID=1000)
greeter-show-manual-login=false
user-session=mate
type=local

# greeter-session=slick-greeter             # did not work
greeter-session=lightdm-gtk-greeter

# autologin-session=lightdm-autologin       # makes weired login screen
autologin-session=mate

# Override Xorg Auto-Detection
# LightDM might not correctly pass the xserver-command parameter to the X server.
# not needed on my systems
# xserver-command=X -config /etc/X11/xorg.conf.d/10-gpu.conf

# use display setup script, not needed on my systems 
# display-setup-script=/usr/local/bin/setup_display.sh
```

#### sample `setup_display.sh`
``` nano /usr/local/bin/setup_display.sh```
```conf
#/bin/bash
# sample setup_display.sh
xrandr --output HDMI-1 --mode 1920x1080 --rate 60
```
```sudo chmod +x /usr/local/bin/setup_display.sh``` 

### check default display manager
```cat /etc/X11/default-display-manager```
```conf
# /etc/X11/default-display-manager
/usr/sbin/lightdm
```

### check user authentification 
The `/etc/pam.d/lightdm` file is a configuration file for the Pluggable Authentication Module (PAM) framework, 
used specifically by the LightDM display manager for managing user authentication.

```bash
# reinstall libpam-gnome-keyring
sudo apt reinstall libpam-gnome-keyring  
nano /etc/pam.d/lightdm
```

```conf
#%PAM-1.0
auth    requisite       pam_nologin.so
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin
@include common-auth
auth    optional        pam_gnome_keyring.so    # enable this for mate, Commenting removed
-auth    optional        pam_kwallet.so         # kde disabled
-auth    optional        pam_kwallet5.so        # kde disabled
@include common-account
session [success=ok ignore=ignore module_unknown=ignore default=bad] pam_selinux.so close
#session required        pam_loginuid.so        # should be commented out on modern systems
session required        pam_limits.so
@include common-session
session [success=ok ignore=ignore module_unknown=ignore default=bad] pam_selinux.so open
session optional        pam_gnome_keyring.so auto_start         # enable this for mate, Commenting removed
-session optional       pam_kwallet.so auto_start               # kde disabled
-session optional       pam_kwallet5.so auto_start              # kde disabled
session required        pam_env.so readenv=1
session required        pam_env.so readenv=1 user_readenv=1 envfile=/etc/default/locale
@include common-password
```

### configure the X-Server 
The file `/etc/X11/xorg.conf.d/10-gpu.conf` is used to configure specific settings for the X server, particularly related to GPUs and display hardware.
It allows users to manually specify or override default configurations for graphics cards, monitors, and other related settings.

```conf
# /etc/X11/xorg.conf.d/10-gpu.conf
Section "Device"
    Identifier "AMDGPU"
    Driver "amdgpu"
    Option "PrimaryGPU" "true"
    BusID "PCI:1:0:0"                   # <------ check for correct PCIe Slot
    Option "DRI" "3"
    Option "DRI2" "off"
    Option "AccelMethod" "glamor"
    Option "TearFree" "true"
    Option "Device" "/dev/dri/card1"    # <------ check for correct card number with `ls -la /dev/dri` 
EndSection
```

### check xsessions
``
```bash
# sudo apt reinstall mate-session-manager   # optional
ls /usr/share/xsessions/
#> mate.desktop
cat /usr/share/xsessions/mate.desktop | grep -E "Exec|TryExec" 
#> Exec=mate-session
#> TryExec=mate-session
```

### check '~/.xinitrc'

```bash
# check '~/.xinitrc'
sudo chmod +x ~/.xinitrc 
nano ~/.xinitrc
```
```conf
# ~/.xinitrc
export DRI_PRIME=1
xhost +SI:localuser:$USER
exec mate-session   # must not be startx here 
```

### check '~/.xprofile'
```bash
# check '~/.xprofile'
sudo chmod +x ~/.xprofile 
nano ~/.xprofile
```
```conf
# ~/.xprofile
# this file enables the use of a discrete GPU in systems with hybrid graphics, such as laptops with both integrated and discrete GPUs
export DRI_PRIME=1  # for card1  
```

### check current desktop session
```bash
echo $XDG_SESSION_DESKTOP
#> mate
```
