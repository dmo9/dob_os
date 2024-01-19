#!/bin/bash
# this script has been designed to run before archinstall in order to
# to set everthing up for installing arch linux.

# LOAD THE CONFIGURATION FILE 
source .conf

function mountDisks()
{
    mkdir $PRIMARY_BOOT_PART_MNT_POINT 
    mkdir -p $BACKUP_DISK_MNT_POINT

    mount $BACKUP_ROOT_PART $BACKUP_DISK_MNT_POINT
    mount $PRIMARY_BOOT_PART $PRIMARY_BOOT_PART_MNT_POINT  
    mount $PRIMARY_ROOT_PART $PRIMARY_ROOT_PART_MNT_POINT 
}

function unmountPrimaryDisk()
{
    umount $PRIMARY_BOOT_PART
    umount $PRIMARY_ROOT_PART
}

function partitionPrimaryDisk()
{
    parted -a optimal $PRIMARY_BOOT_PART mkpart "EFI system partition" fat32 0% $PRIMARY_BOOT_PART_SIZE set 1 esp on
    parted -a optimal $PRIMARY_ROOT_PART mkpart "root partition" ext4 $PRIMARY_BOOT_PART_SIZE 100% set 2 root on
}

function connectToWifi(){
    nmtui
}


function formatPrimaryDisk()
{
    unmountDisks
    mkfs.ext4 $PRIMARY_ROOT_PART
    mkfs.fat -F 32 $PRIMARY_BOOT_PART
}

function installEssentialPackages(){
    pacstrap -K /mnt $ESSENTIAL_PACKAGES
}

function genfstab()
{
    genfstab -U /mnt >> /mnt/etc/fstab
}



help()
{
   # Display Help
   echo "Usage: commandName [OPTIONS]"
   echo "This script is used to install arch linux."
   echo
   echo "OPTIONS"
   echo "   -m     mounts the primary and backup drives"
   echo "   -h     displays this help message"
   echo "   -u     unmounts the primary disk"
   echo "   -w     setup wifi via nmtui"
   echo "   -c     wipes the primary disk & does a clean install. Be careful!"
   echo "   -r     copies files from the backup disk to the primary disk"
   echo "   -l     list the paths of the primary & backup disks"
}

# https://www.redhat.com/sysadmin/arguments-options-bash-scripts


if [ $EUID != 0 ]
then
    echo "ERROR: must be root"
else
    while getopts ":hmuwcrl" option; do
        case $option in
            h) # display Help
                help
                exit;;

            m) # mount the drives
                mountDisks
                exit;;

            u) #unmount the primary disk 
                unmountPrimaryDisk;;

            w) # connect to wifi 
                connectToWifi
                exit;;

            c) # perform a clean install 
                while true; do
                    read -p "You've selected to do a clean install on the primary disk; this will erase all its contents. Proceed? [Y/N] " yn
                    case $yn in
                        [Yy]*) 
                            pacman -Syu
                            partitionPrimaryDisk
                            formatPrimaryDisk
                            installEssentialPackages
                            genfstab
                            exit;;
                        [Nn]* ) 
                            exit;;
                        * )
                            echo "Please answer yes or no.";;
                    esac
                done;;

            l)
                echo "Primary disk boot partition: $PRIMARY_BOOT_PART"
                echo "Primary disk root partition: $PRIMARY_ROOT_PART"
                echo "Backup disk root partition: $BACKUP_DISK_ROOT_PART"
                exit;;

            r) #restore from backup
                ECHO "RESTORE FROM BACKUP";;
            
            
            \?) # Invalid option
                echo "Error: Invalid option"
                exit;;

        esac
    done    
fi

