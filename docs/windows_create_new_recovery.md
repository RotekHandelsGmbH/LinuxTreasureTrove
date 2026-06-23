# Create a new Recovery Partition

## Adjust Partition Sizes
move EFI Partition the the end and make some space for Recovery Partition (use ct-rescue, Partition-Minitool) 
You can be generouse here when using sparse disks (thin provisioned).
Adjust the disk size of the VM in Proxmox as needed, I make extra 50GB Space for Recovery Partition.

## Create new Recovery
```bash 
# Powershell as Admin
diskpart
list disk
select disk X
create partition primary # [size=50000] skip the size to use all available space
format fs=ntfs label="Recovery" quick
assign letter=R

# on MBR: set Partition as Recovery Type 
set id=27 override
# os GPT: set Partition as Recovery Type
set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
# exit diskpart
exit

# if You dont have winre.wim at C:\Windows\System32\Recovery\winre.wim
# mount Windows ISO on Drive D:
# get the correct index version 
dism /get-wiminfo /wimfile:"D:\sources\install.wim"  # Windows 11 Pro = Index 5 on my machine
# mount the correct WIM File
mkdir C:\Temp\Mount
dism /mount-wim /wimfile:"D:\sources\install.wim" /index:5 /mountdir:"C:\Temp\Mount" /ReadOnly
copy "C:\Temp\Mount\Windows\System32\Recovery\winre.wim" "C:\Windows\System32\Recovery\winre.wim"
dism /unmount-wim /mountdir:"C:\Temp\Mount" /discard
rmdir C:\Temp\Mount

## copy wim to recovery partition
mkdir R:\Recovery\WindowsRE
copy "C:\Windows\System32\Recovery\winre.wim" "R:\Recovery\WindowsRE\winre.wim"
reagentc /setreimage /path R:\Recovery\WindowsRE
reagentc /enable
reagentc /info

# copy all drivers of the machine to WINRE.wim (especially useful on KVM, VMWare, etc. to get all disk, network, graphic drivers): 
mkdir C:\WinRE_Mod
mkdir C:\WinRE_Mod\mount
mkdir C:\WinRE_Mod\Drivers
pnputil /export-driver * C:\WinRE_Mod\Drivers
copy R:\Recovery\WindowsRE\WinRE.wim C:\WinRE_Mod\
dism /mount-wim /wimfile:C:\WinRE_Mod\WinRE.wim /index:1 /mountdir:C:\WinRE_Mod\mount
dism /image:C:\WinRE_Mod\mount /add-driver /driver:C:\WinRE_Mod\Drivers /recurse
dism /unmount-wim /mountdir:C:\WinRE_Mod\mount /commit
copy C:\WinRE_Mod\WinRE.wim R:\Recovery\WindowsRE\
copy C:\WinRE_Mod\WinRE.wim C:\Windows\System32\Recovery\
reagentc /setreimage /path R:\Recovery\WindowsRE
reagentc /enable
reagentc /info
diskpart 
select disk 0
list volume
select volume x
remove letter=R
reagentc /enable
reagentc /info
# TEST with F11 on Startup

## other useful commands I did not need here 
# set the new recovery image as standard
reagentc /setosimage /path R:\Recovery\WindowsRE /target C:\Windows /index 1

```