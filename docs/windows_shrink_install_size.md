# shrink windows11 installation size

##  Disabling Delivery Optimization

Windows Delivery Optimization is mostly unnecessary for home PCs and consumes disk space without real benefit. Turning it off can permanently free up storage space – in the example, 3.5 GB were recovered.
Where to turn it off in Windows 11:  
Go to Settings > Windows Update > Advanced options > Delivery Optimization, and disable "Allow downloads from other PCs."

or: 
```powershell
# Powerhell
# Set the Delivery Optimization download mode to 0 (disabled)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -Type DWord

# Optional: Create the key if it doesn't exist
If (-Not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -PropertyType DWord -Value 0 -Force
```

## Cleaning Up Temporary Files - on a regular basis
The next standard step is removing temporary files In our example, 2.7 GB were recovered, mostly by checking the option "Windows Update Cleanup." Don’t be misled if 
Windows predicts only a few hundred megabytes of space will be freed – that’s just an estimate and often far from the actual result.
– found in Windows Settings under:  
"System > Storage > Temporary files."  

or : 
```powershell
# Powerhell
# Deletes files in %TEMP%
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Optional: Clear Windows Update files
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
```

## Enabling System File Compression
typical Windows installations are usually uncompressed (“The system is not in a compressed state”), unless installed on very small drives like a 64 GB SSD. 
The following command forces Windows to always compress the contents of the system folder C:\Windows:

```powershell
# Powerhell
compact /compactos:always
```

In our example, this freed up 2.4 GB, and in some cases even 4–5 GB.

The downside is a theoretical, minimal performance loss when reading system files, as the CPU has to decompress them. On any reasonably modern system, however, this impact is negligible. Whether to enable compression is mostly a matter of preference: do you want more free space or save a few CPU cycles?
(useless for vm on compressed ZFS Volumes)

## Disabling Hibernation

Deleting the file C:\hiberfil.sys frees up 3 GB of space in our example — simply run this command in an admin terminal:

```powershell
# Powerhell
powercfg /h off
```

However, this disables hibernate (Suspend-to-Disk), where RAM contents are saved to disk before the system powers down. This also removes Hybrid Sleep, which combines Suspend-to-Disk and Suspend-to-RAM for faster wake-up and battery-safe backup.

Additionally, without hiberfil.sys, Windows can no longer use Fast Startup, which allows quicker boot times by partially hibernating the system during shutdown. Most systems won’t show a noticeable difference, but if boot time becomes an issue, this command offers a compromise:

```powershell
# Powerhell
powercfg /h /type reduced
```

This reduces the size of hiberfil.sys instead of disabling it completely — Fast Startup remains available, while full hibernation and Hybrid Sleep are disabled.

## Disabling System Restore — But Be Aware of the Risks

Another way to save space is disabling System Protection (also known as System Restore or Restore Points). This feature automatically creates restore points before updates, allowing users to roll back to a working system if something goes wrong. While it was disabled by default in some Windows 10 versions, it’s active again in fresh Windows 11 installations (version 24H2), unless installed on very small drives.

The setting is somewhat hidden:
Right-click the Start button → click System → under Device specifications, click System Protection.
If protection is set to "On" for drive C:, click Configure, select "Disable system protection", and confirm with OK.
In our test, this freed up 2.9 GB.

⚠️ Unlike previous tips, this one carries real risk: If a bad update corrupts the system, you might lose an easy rollback path. You’d then need to use recovery tools like Windows RE or third-party boot environments to fix the issue manually.

```powershell
# Powerhell
# Disable System Restore for C: drive
Disable-ComputerRestore -Drive "C:\"

# Confirm it is disabled
(Get-ComputerRestorePoint -ErrorAction SilentlyContinue) -eq $null
```

## Disabling Windows Reserved Storage — But Monitor Updates Carefully

Another space-saving step—though not always risk-free—is disabling Reserved Storage for Windows Update. This feature typically reserves 5–7 GB of disk space, which remains unused by other apps or files and is reserved exclusively for Windows Update and related processes.

To disable Reserved Storage, run this PowerShell command as Administrator:

```powershell
Set-WindowsReservedStorageState -State Disabled
```

If Windows throws an error saying the reserved storage is in use due to ongoing updates, restart the PC or wait a few minutes and try again.
In our test, this freed up 5.9 GB.

⚠️ Warning: Windows updates—especially feature updates—can be large. If you disable reserved storage and your system drive becomes full, updates (including security patches) may fail to install. Be sure to regularly check Windows Update for failed updates if you apply this tweak on a nearly full drive.

