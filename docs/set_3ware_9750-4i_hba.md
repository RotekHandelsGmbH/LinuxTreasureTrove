# set 3Ware 9750-4i Controller from Raid to HBA Mode

get more information at 
[Broadcom](https://www.broadcom.com/support/knowledgebase/1211161496893/megaraid-3ware-and-hba-support-for-various-raid-levels-and-jbod-) 
for possible modes on a specific controller

9750-4i does not really support IT mode, but drives can be set to single mode to use with ZFS

```bash
# set 3Ware Controller from Raid to HBA Mode
./tw_cli show

# Ctl   Model        (V)Ports  Drives   Units   NotOpt  RRate   VRate  BBU
# ------------------------------------------------------------------------
# c0    9750-4i      3         3        1       0       1       1      OK     

./tw_cli /c0 show all

# Unit  UnitType  Status         %RCmpl  %V/I/M  Stripe  Size(GB)  Cache  AVrfy
# ------------------------------------------------------------------------------
# u0    RAID-5    OK             -       -       256K    1862.62   RiW    ON     
#
# VPort Status         Unit Size      Type  Phy Encl-Slot    Model
# ------------------------------------------------------------------------------
# p0    OK             u0   931.51 GB SATA  0   -            Hitachi HDS721010CL 
# p1    OK             u0   931.51 GB SATA  1   -            Hitachi HDT721010SL 
# p2    OK             u0   931.51 GB SATA  2   -            Hitachi HDT721010SL 
#
# Name  OnlineState  BBUReady  Status    Volt     Temp     Hours  LastCapTest
# ---------------------------------------------------------------------------
# bbu   On           Yes       OK        OK       OK       129    xx-xxx-xxxx

./tw_cli /c0/u0 del
# Deleting /c0/u0 will cause the data on the unit to be permanently lost.
# Do you want to continue ? Y|N [N]: y
# Deleting unit c0/u0 ...Done.

./tw_cli /c0 show phy
#                              Device              --- Link Speed (Gbps) ---
# Phy     SAS Address          Type     Device     Supported  Enabled  Control
# -----------------------------------------------------------------------------
# phy0    500605b00173de07     SATA     /c0/p0     1.5-6.0    3.0      Auto
# phy1    500605b00173de06     SATA     /c0/p1     1.5-6.0    3.0      Auto
# phy2    500605b00173de05     SATA     /c0/p2     1.5-6.0    3.0      Auto
# phy3    500605b00173de04     -        -          1.5-6.0    -        Auto
# phy4    500605b00173de03     -        -          1.5-6.0    -        Auto
# phy5    500605b00173de02     -        -          1.5-6.0    -        Auto
# phy6    500605b00173de01     -        -          1.5-6.0    -        Auto
# phy7    500605b00173de00     -        -          1.5-6.0    -        Auto

./tw_cli /c0 add type=single disk=0
# Creating new unit on controller /c0 ... Done. The new unit is /c0/u0.
# Setting AutoVerify=ON for the new unit ... Done.
# Setting default Storsave policy to [balance] for the new unit ... Done.
# Setting default Command Queuing policy for unit /c0/u0 to [on] ... Done.
# Setting write cache = ON for the new unit ... Done.

./tw_cli /c0 add type=single disk=1
# Creating new unit on controller /c0 ... Done. The new unit is /c0/u1.
# Setting AutoVerify=ON for the new unit ... Done.
# Setting default Storsave policy to [balance] for the new unit ... Done.
# Setting default Command Queuing policy for unit /c0/u1 to [on] ... Done.
# Setting write cache = ON for the new unit ... Done.

./tw_cli /c0 add type=single disk=2
# Creating new unit on controller /c0 ... Done. The new unit is /c0/u2.
# Setting AutoVerify=ON for the new unit ... Done.
# Setting default Storsave policy to [balance] for the new unit ... Done.
# Setting default Command Queuing policy for unit /c0/u2 to [on] ... Done.
# Setting write cache = ON for the new unit ... Done.

./tw_cli /c0 show
# Unit  UnitType  Status         %RCmpl  %V/I/M  Stripe  Size(GB)  Cache  AVrfy
# ------------------------------------------------------------------------------
# u0    SINGLE    OK             -       -       -       931.312   RiW    ON
# u1    SINGLE    OK             -       -       -       931.312   RiW    ON
# u2    SINGLE    OK             -       -       -       931.312   RiW    ON
# 
# VPort Status         Unit Size      Type  Phy Encl-Slot    Model
# ------------------------------------------------------------------------------
# p0    OK             u0   931.51 GB SATA  0   -            Hitachi HDS721010CL
# p1    OK             u1   931.51 GB SATA  1   -            Hitachi HDT721010SL
# p2    OK             u2   931.51 GB SATA  2   -            Hitachi HDT721010SL
# 
# Name  OnlineState  BBUReady  Status    Volt     Temp     Hours  LastCapTest
# ---------------------------------------------------------------------------
# bbu   On           Yes       OK        OK       OK       128    xx-xxx-xxxx

lsblk
# NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda      8:0    0 465.8G  0 disk
# ├─sda1   8:1    0  1007K  0 part
# ├─sda2   8:2    0     1G  0 part
# └─sda3   8:3    0 464.8G  0 part
# sdb      8:16   0 931.3G  0 disk
# sdc      8:32   0 931.3G  0 disk
# sdd      8:48   0 931.3G  0 disk

```