#!/bin/bash
# To mount a samba share to Linux (GNU/Linux)
# by using shell. That's the sense of my existence.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Tested with Lubuntu (Ubuntu 15.10)
# Run me with sudo. See the comments for my steps. Feel free to
# pull requests for me on github (https://github.com/NazimKenan/smallShelly).
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Clearing terminal and basic variables
clear
myName="$0" #My name is changeable
myAge="0.1" #I am still a baby
myHome="https://github.com/NazimKenan/smallShelly" #You can visit me.

#Check if cifs-utils is installed already
function package_exists() {
    return dpkg -l "$1" &> /dev/null
}
if ! package_exists cifs-utils ; then
sudo apt-get install cifs-utils
fi

#User asked for typing target and new path
echo "$myName - To mount a samba share to Linux (GNU/Linux)"
echo "by using shell. That's the sense of my existence."
echo "Visit $myHome for further information."
read -p "Type the target directory (local or server) you want to mount: " targetPath
read -p "Type your username for the target directory: " user
read -p "Type your domain (default: 'WORKGROUP'): " domain
read -p "Type the local directory to which the share should be mounted: " localPath
echo ""
clear

#Are the informations correct?
echo "Are these informations correct?"
echo "Target:	$targetPath"
echo "User:	$user"
echo "Domain:	$domain"
echo "Local:	$localPath"
echo ""
read -p "Please type 'yes' to proceed or anything else to abort: " informationCorrect
if [ "$informationCorrect" != "yes" ]
	then
	echo "Process aborted."
	exit 0
fi

#Check if localPath already exists and create path if not
if [ ! -d "$localPath" ]; then
sudo mkdir $localPath
fi

#Mounting as cifs
sudo mount -t cifs $targetPath $localPath -o user=$user,domain=$domain

#Printing information
clear
echo "********************************"
echo "Target path:	$targetPath"
echo "Local path:	$localPath"
echo "Mounted."
echo "$myName ($myAge) - Visit $myHome for further information."
exit 0
