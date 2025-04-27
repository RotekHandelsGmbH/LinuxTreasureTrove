# set LSI Megaraid Controller from Raid to HBA Mode

```bash
# set to JBOD: 

# JBOD einschalen - Achtung auf Controlleradresse !
sudo /opt/MegaRAID/MegaCli/MegaCli64 -AdpSetProp -EnableJBOD -1 -aALL

# Enclosure IDs und Slots anzeigen 
sudo /opt/MegaRAID/MegaCli/MegaCli64 -CfgDsply -aALL | grep -E '(Enclosure Device|Slot)'

# Disk Group anzeigen (wenn vorher mit Raid formattiert) 
sudo /opt/MegaRAID/MegaCli/MegaCli64 -CfgDsply -aALL | grep -E '(DISK GROUP)'

# Raid löschen 
sudo /opt/MegaRAID/MegaCli/MegaCli64 -CfgLdDel -L0 -a0
# Adapter 0: Deleted Virtual Drive-0(target id-0)

# Platten zu JBOD machen 
sudo /opt/MegaRAID/MegaCli/MegaCli64 -PDMakeJBOD -PhysDrv [252:0,252:1,252:2,252:3,252:4,252:5,252:6,252:7] -a0
# Adapter: 0: EnclId-252 SlotId-0 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-1 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-2 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-3 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-4 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-5 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-6 state changed to JBOD.
# Adapter: 0: EnclId-252 SlotId-7 state changed to JBOD.
```
