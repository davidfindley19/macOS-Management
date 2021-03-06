#!/bin/sh

# Purpose: To simplify the DEP enrollment process for Macs.
# Author: David Findley
# Date: December 20, 2017
# Version: 1.1
# Removed the local storage requirement.

if [ "$USER" != "root" ]; then
echo "************************************"
	echo "You are attempting to execute this process as user $USER"
	echo "Please execute the script with elevated permissions."
	exit 1
fi

clear

# Now we need to authenticate with domain credentials
echo "We need to authenticate with your domain credentials to proceed: "
read -p 'Please enter your network username:' domainusername
read -s -p 'Please enter your AD password: ' domainpass
clear

### Begin Functions

# Basic function to install the Quick Add pkg for JAMF.

function jamf_install()
{
  echo "\nInstalling the Quick Add package. This may take a few moments..."

  # Now we need to make a mount point for the NFS share.
  
  echo "\nMaking mount point directory"
  mkdir /Volumes/FOLDER
  echo "\nMounting remote network location"
  mount_smbfs "//$domainusername:$domainpass@FQDN/Scratch" /Volumes/FOLDER
  /usr/sbin/installer -pkg /Volumes/PATH/TO/DRIVE/QuickAdd.pkg -target "/"
  echo "\nThe JAMF Management software has been installed."
  echo "\nUnmounting network drive."
  umount /Volumes/scratch
  clear
}

# Used to force the machine to check in with JSS

function recon()
{ 
	echo "\nChecking in with JSS"
	jamf recon
	clear
}

# Force policy retrieval - like gpupdate, but for Macs.

function policy()
{
  echo "\nForcing policy retrieval for machine"
	jamf policy
	clear
} 

function do_all()
{
	jamf_install
	recon
	policy
	clear
}

# Have this as a hidden feature to remove the JAMF software
function remove_jamf()
{
	jamf removeFramework
	clear
}

### Begin Menu Functions

function read_options()
{
	local choice
	read -p "Choose and option: " number
	case $number in 
		1) do_all ;;
		2) jamf_install ;;
		3) recon ;;
		4) policy ;;
		5) exit 0 ;;
		6) remove_jamf ;;
	esac 
}

function menu()
{
	echo "**********************"
	echo "1) Install JAMF QuickAdd and update policies "
	echo "2) Install JAMF QuickAdd Package Only "
	echo "3) Run Recon Tool for JAMF "
	echo "4) Update JAMF Policies "
	echo "5) Exit "

}

while true 
	do 
	menu
	read_options
done	
