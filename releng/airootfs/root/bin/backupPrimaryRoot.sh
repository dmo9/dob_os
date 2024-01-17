#!/bin/bash

# identify the root partitions of each disk (primary and backup) 
primaryDiskRootPart=/dev/disk/by-id/nvme-CT500P3PSSD8_2244E680491F-part2
backupDiskRootPart=/dev/disk/by-id/ata-WDC_WD5000LPCX-24C6HT0_WD-WX31A2510N4Y-part1

# mount the disks 
mkdir -p /mnt/backup
mkdir -p /mnt/primary
mount $backupDiskRootPart /mnt/backup
mount $primaryDiskRootPart /mnt/primary

# copy the contents from the primary disk to the backup disk
# preserve permissions, owners, groups, etc. 
rsync -arptugovp  /mnt/primary /mnt/backup/primary-disk/root-partition

# unmount the disks 
umount $backupDiskRootPart
umount $primaryDiskRootPart

