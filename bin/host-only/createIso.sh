#!/bin/bash
# This script creates an iso using archiso & our iso profile folder

# LOAD THE CONFIGURATION FILE 
source /home/dob/dob_os/.conf



updateSystem(){
    # get everything on the system setup
    pacman -Syu --noconfirm

}

rmOldIso(){
    rm -r $TMP_ISO_PATH
    rm $ISO_OUTPUT_DIR/*.iso
}

getIsoName(){
    echo $(ls $ISO_OUTPUT_DIR | grep -E '\.iso$')
}

addIsoToFlashDrive(){
    isoName=$(getIsoName)
    mount $LIVE_ISO_DISK /mnt
    sleep 1 # wait to ensure the iso is done 
    runuser dob -c "bsdtar -xvf $ISO_OUTPUT_DIR/$isoName -C /mnt"
    sudo umount $LIVE_ISO_DISK
}

testIsowithVirtualMachine(){
    isoName=$(getIsoName)
    export XDG_RUNTIME_DIR=/run/user/1000 #BC THIS SCRIPT IS RUN AS ROOT
    runuser dob -c "run_archiso -ui $ISO_OUTPUT_DIR/$isoName"
}

copyScriptsToProfileDir(){
    # copy all files from the bin/ folder to the airrootfs folder so they can be accessed from the live iso
    # the .automated_script.sh will run at startup and do things like give these scripts the right permissions.
    rm -r $PROFILE_DIR/airootfs/root/bin/*
    cp -r $ISO_BIN_DIR/*.sh $PROFILE_DIR/airootfs/root/bin/
}

copyConfToProfileDir(){
    cp -r $CONF_DIR/*.conf $PROFILE_DIR/airootfs/root/bin/
}

fixLicenseMissingError(){
    # at the time of this script, not having this file causes an error to be thrown during creation of the iso
    # so therefore, it is created manually. Not sure why it's throwing the error. 
    mkdir -p $TMP_ISO_PATH/x86_64/airootfs/usr/share/licenses/common/GPL2
    touch $TMP_ISO_PATH/x86_64/airootfs/usr/share/licenses/common/GPL2/license.txt

}

generateIso(){
    #generate the iso using the archiso package
    mkarchiso -vrw $TMP_ISO_PATH -o $ISO_OUTPUT_DIR $PROFILE_DIR
}


help()
{
   # Display Help
   echo "Usage: commandName [OPTIONS]"
   echo "This script is used to generate a live recovery ISO for arch linux."
   echo
   echo "OPTIONS"
   echo "   -h     prints this help message"
   echo "   -g     generates a new iso from the profile (releng) directory"
   echo "   -f     flashes the iso to the USB drive specified in the configuration file, .conf"
   echo "   -t     starts a virtual machine via QEMU to test the live ISO"
}

ISO_GENERATED=false
if [ "$EUID" != 0 ]
then
    echo "ERROR: must run this script as root"
    exit
else 
    while getopts ":hgft" option; do
        case $option in
            h) # display Help
                help
                exit;;

            g) # generate the ISO
                updateSystem
                rmOldIso
                copyScriptsToProfileDir
                fixLicenseMissingError
                generateIso
                $ISO_GENERATED=true;;

            f) # flash the USB stick
                addIsoToFlashDrive;;

            t) # start a virtual machine to test the iso
                if [ $ISO_GENERATED == true ]
                then
                    testIsowithVirtualMachine
                    exit
                else
                    echo "ERROR: new iso must be generated first. Use the -g flag or see help for usage details"
                fi;;
    

            \?) # Invalid option
                echo "Error: Invalid options. See help for more details."
                exit;;

        esac
    done 
fi



