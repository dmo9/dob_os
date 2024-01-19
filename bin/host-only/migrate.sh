#!/bin/bash
# creates two text files: one which contains a list of all pacman installed packages on the current
# system and the other which contains all the aur packages.

# LOAD THE CONFIGURATION FILE 
source /home/dob/dob_os/.conf

timestamp() {
  date +"%m/%d/%Y"
}

# create the lists of installed packages 
pacman -Qqen > $PACMAN_LIST_OUTPUT_PATH
pacman -Qqem > $AUR_LIST_OUTPUT_PATH


# add the .config folder to git 
echo "Attempting to commit .config folder"
cd /home/dob/.config
git add -A
git commit -m "$(timestamp) - automated commit"
runuser dob -c "git push"

# add the dob_os folder to git 
echo "Attempting to commit dob_os folder"
cd /home/dob/dob_os
git add -A
git commit -m "$(timestamp) - automated commit"
runuser dob -c "git push"