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
#> GRUB_CMDLINE_LINUX_DEFAULT="[...] [...] [...] systemd.unit=graphical.target radeon.si_support=0 amdgpu.si_support=1 amdgpu.dc=1 drm.primary=PCI:0000:01:00.0"

# - "systemd.unit=graphical.target": parameter is used to configure the system to boot directly into the graphical user interface (GUI).
# It sets the systemd target to "graphical.target," which starts all necessary services for a graphical session.
# This can be added as a kernel boot parameter or used in system configuration for GUI-based environments.

# - "systemd.unit=multi-user.target": parameter configures the system to boot into a non-graphical, multi-user mode.
# It sets the systemd target to "multi-user.target," which starts network services and allows multiple users but does not load a GUI.
# This is commonly used for server environments or troubleshooting without a graphical interface.

# - "radeon.si_support=0": Disables support for Southern Islands (SI) GPUs in the Radeon driver.
# - "amdgpu.si_support=1": Enables support for Southern Islands (SI) GPUs in the AMDGPU driver.
# - "amdgpu.dc=1": Activates the Display Core Driver in the AMDGPU driver.
# - "drm.primary=PCI:0000:01:00.0": Specifies the primary GPU device by its PCI address.
# These settings are useful for optimizing GPU usage, especially when switching between Radeon and AMDGPU drivers.
```

```bash
sudo update-grub
sudo initramfs -u
sudo reboot now
```

## if radeon is still in use, force amdgpu

```bash
echo "options amdgpu si_support=1" > /etc/modprobe.d/amdgpu.conf
echo "options radeon si_support=0" > /etc/modprobe.d/radeon.conf
sudo initramfs -u
sudo reboot now
# after
lspci -k | grep -EA3 'VGA|3D|Display'
# amdgpu must be in use !
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

---

# gpu usage in the lxc container (here for two HD7990 cards)

## for the lxc container 

```bash
# on the host : 
ls -l /dev/kfd /dev/dri

/dev/kfd:
crw-rw---- 1 root render 236, 0 Mar 11 20:39 /dev/kfd

/dev/dri:
total 0
drwxr-xr-x 2 root root        160 Mar 11 20:39 by-path
crw-rw---- 1 root video  226,   0 Mar 11 20:39 card0
crw-rw---- 1 root video  226,   1 Mar 11 20:39 card1
crw-rw---- 1 root video  226,   2 Mar 11 20:39 card2
crw-rw---- 1 root render 226, 128 Mar 11 20:39 renderD128
crw-rw---- 1 root render 226, 129 Mar 11 20:39 renderD129
crw-rw---- 1 root render 226, 130 Mar 11 20:39 renderD130
```

Given the host's actual device info:

/dev/kfd --> major:minor = 236:0
/dev/dri/ --> 226:x - multiple GPU devices/cards
We need to adjust the container configuration accordingly:

```bash
# /etc/pve/lxc/<ctid>.conf
# Allow /dev/kfd
lxc.cgroup2.devices.allow: c 236:0 rwm
lxc.mount.entry: /dev/kfd dev/kfd none bind,optional,create=file

# Allow /dev/dri for GPU devices
lxc.cgroup2.devices.allow: c 226:* rwm
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
```
Verify Device Visibility inside the container:
Once restarted, enter the container and verify:

```bash
ls -l /dev/kfd /dev/dri
You should now see similar entries as your host.
```

## install openl and vulkan drivers (on the lxc client)

```bash
sudo apt install mesa-opencl-icd clinfo mesa-vulkan-drivers vulkan-tools
ls -la /dev/kfd   # check permissions, add user to video, renderer, whatever is needed 
ls -la /dev/dri   # check permissions, add user to video, renderer, whatever is needed
clinfo            # try as root if permissions error and fix those afterwards
vulkaninfo        # try as root if permissions error and fix those afterwards
```

## install Mesa's VA-API (Video Acceleration API) driver (on the lxc client, only if X11 or wayland is running)

```bash
sudo apt install mesa-va-drivers libva2 libva-drm2 libva-x11-2 vainfo
vainfo
```


---

# Documentation: Relationship Between AMD GPU Drivers, LightDM, MATE, and Xserver  

This document outlines the roles, dependencies, and workflow between AMD GPU drivers, the X.Org Server (Xserver), LightDM (Light Display Manager), and the MATE desktop environment in a typical Linux-based graphical system.  

---

## **1. Component Overview**  

### **1.1 AMD GPU Drivers**  
- **Role**: Low-level software that enables the operating system to communicate with AMD graphics hardware.  
  - Manages GPU resource allocation, rendering, display output, and hardware acceleration.  
  - Provides kernel modules (e.g., `amdgpu`) and user-space libraries (e.g., `Mesa 3D` for OpenGL/Vulkan).  
- **Dependencies**:  
  - Requires compatibility with the Linux kernel and Xserver/X.Org or Wayland.  

### **1.2 X.Org Server (Xserver)**  
- **Role**: Display server implementing the X11 protocol to manage graphical output and input devices (keyboard, mouse).  
  - Renders windows, handles screen resolution, and delegates GPU tasks to drivers.  
  - Uses the AMD GPU driver via the `xf86-video-amdgpu` X.Org driver module for hardware acceleration.  
- **Dependencies**:  
  - Requires a functional GPU driver (e.g., AMD) to interface with hardware.  

### **1.3 LightDM**  
- **Role**: Display manager that launches and manages user sessions.  
  - Displays the login screen, authenticates users, and starts the desktop environment.  
  - Runs as an X client (or Wayland compositor), relying on Xserver for graphical rendering.  
- **Dependencies**:  
  - Requires Xserver (or Wayland) to operate.  
  - Configured to launch the MATE desktop session.  

### **1.4 MATE Desktop Environment**  
- **Role**: User-facing GUI built on GNOME 2 libraries.  
  - Provides panels, window management (Marco WM), file manager (Caja), and other utilities.  
  - Interfaces with Xserver via X11 protocol for drawing windows and handling input.  
- **Dependencies**:  
  - Requires Xserver (or Wayland) for display and input management.  

---

## **2. Workflow and Interaction**  

### **2.1 Boot Process Flow**  
1. **Kernel Initialization**:  
   - The Linux kernel loads the `amdgpu` driver module to control the AMD GPU.  

2. **Xserver Launch**:  
   - X.Org Server starts, using the `amdgpu` driver to detect displays and configure resolutions.  
   - GPU acceleration is enabled via Xserver’s `xf86-video-amdgpu` module and Mesa libraries.  

3. **LightDM Activation**:  
   - LightDM starts as a service, connects to Xserver, and displays the graphical login screen.  
   - LightDM’s Xsession script prepares the environment for the user session.  

4. **User Login**:  
   - After authentication, LightDM launches the user’s selected session (e.g., `mate-session`).  

5. **MATE Desktop Startup**:  
   - `mate-session` initializes the MATE environment:  
     - Window manager (Marco) registers with Xserver to handle window placement/compositing.  
     - MATE components (panel, apps) communicate with Xserver for rendering.  
   - Xserver delegates rendering tasks to the AMD driver for hardware-accelerated performance.  

---

## **3. Key Dependencies and Interactions**  

| Component          | Depends On     | Interaction Purpose                                                                |  
|--------------------|----------------|------------------------------------------------------------------------------------|  
| **AMD GPU Driver** | Linux Kernel   | Direct hardware control (GPU initialization, memory management).                   |  
| **Xserver**        | AMD GPU Driver | Translates X11 commands into GPU-specific instructions (e.g., OpenGL calls).       |  
| **LightDM**        | Xserver        | Renders the login screen and launches user sessions via Xserver.                   |  
| **MATE**           | Xserver        | Uses X11 protocol for window rendering, input handling, and display configuration. |  

---

## **4. Configuration Files**  
- **AMD Driver**:  
  - Kernel parameters in `/etc/default/grub` or `modprobe.d` configurations.  
  - X.Org settings in `/etc/X11/xorg.conf.d/20-amdgpu.conf`.  
- **Xserver**:  
  - Main configuration: `/etc/X11/xorg.conf`.  
- **LightDM**:  
  - Session configuration: `/etc/lightdm/lightdm.conf` (sets `user-session=mate`).  
- **MATE**:  
  - Customizations: `~/.config/mate/*` (user-specific settings).  

---

## **5. Troubleshooting Notes**  
- **AMD Driver Issues**:  
  - Symptoms: Poor performance, screen tearing, or Xserver crashes.  
  - Debug: Check `Xorg.0.log` for GPU initialization errors; verify `amdgpu` kernel module is loaded.  
- **Xserver Failures**:  
  - Symptoms: Blank screen or LightDM not starting.  
  - Debug: Use Ctrl+Alt+F2 to switch to a TTY; inspect logs at `/var/log/Xorg.0.log`.  
- **LightDM/MATE Issues**:  
  - Symptoms: Login loop or missing desktop elements.  
  - Debug: Reinstall MATE packages or reset user configs in `~/.config/mate`.  

---

## **6. Alternative Stacks**  
- **Wayland**: Replaces Xserver with compositors like `Weston` or `Mutter` (used by GNOME).  
- **Other Display Managers**: GDM, SDDM.  
- **Other Desktop Environments**: GNOME, KDE Plasma, Xfce.  

--- 
