#!/bin/bash
# This script creates an iso using archiso & our iso profile folder

isoOutputDir=/home/dob/backup/dob_os
profileDir=/home/dob/backup/dob_os/releng
liveIsoUsb=/dev/disk/by-id/usb-VendorCo_ProductCode_3910691084156330299-0:0-part1


if [ "$EUID" != 0 ]
    then
        echo "must run this script as root"
        exit
    else 
        
        #get everything on the system setup
        pacman -Syu
        rm -r /tmp/tmp
        rm $isoOutputDir/*.iso

        # at the time of this script, not having this file causes an error to be thrown duriong creation of the iso
        # so therefore, it is created manually.
        mkdir -p /tmp/tmp/x86_64/airootfs/usr/share/licenses/common/GPL2
        touch /tmp/tmp/x86_64/airootfs/usr/share/licenses/common/GPL2/license.txt


        #generate the iso using archiso
        mkarchiso -vr -w /tmp/tmp -o $isoOutputDir $profileDir

        # add the iso to the flash drive
        isoName=$(ls $isoOutputDir | grep -E '\.iso$')
        mount $liveIsoUsb /mnt
        sleep 1 # wait to ensure the iso is done 
        runuser dob -c "bsdtar -xvf $isoOutputDir/$isoName -C /mnt"
        sudo umount $liveIsoUsb


        # iso test here
        export XDG_RUNTIME_DIR=/run/user/1000
        runuser dob -c "run_archiso -ui $isoOutputDir/$isoName"
    fi 




