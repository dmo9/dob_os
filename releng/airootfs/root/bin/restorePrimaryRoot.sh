#!/bin/bash

# LOAD THE CONFIGURATION FILE 
source /home/dob/dob_os/.conf

# identify the root partitions of each disk (primary and backup) 
primaryDiskRootPart=/dev/disk/by-id/nvme-CT500P3PSSD8_2244E680491F-part2
backupDiskRootPart=/dev/disk/by-id/ata-WDC_WD5000LPCX-24C6HT0_WD-WX31A2510N4Y-part1

# mount the disks 
mkdir -p /mnt/backup
mkdir -p /mnt/primary
mount $backupDiskRootPart /mnt/backup
mount $primaryDiskRootPart /mnt/primary

# copy the contents from the backup disk to the primary disk  
# preserve permissions, owners, groups, etc. 
rsync -arptugovp /mnt/backup/primary-disk/root-partition /mnt/primary

# unmount the disks 
umount $backupDiskRootPart
umount $primaryDiskRootPart

