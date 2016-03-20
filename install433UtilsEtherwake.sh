#!/bin/bash
myName="433UtilsEtherwakeInstaller"
myHome="http://www.github.com/NazimKenan/"
myIntention="To install and configure 433Utils, wiringPi, etherwake and give root-permissions to www-data"
###########################################################################################
###########################################################################################
function package_exists() {
    return dpkg -l "$1" &> /dev/null
}
function package_install() {
	if ! package_exists $1 ; then
	echo "$1 not found. Start to download and install now."
	sudo apt-get install $1
else
	echo "$1 already installed."
fi
}
function updateUpgrade() {
	read -p "Do you want to update and upgrade by apt-get? Type yes: " yes
	if [[ $yes = 'yes' ]] ; then
		sudo apt-get update && sudo apt-get -y upgrade
	else
		echo "Continuing without 'sudo apt-get update && apt-get -y upgrade'..."
	fi
}
function install_wiringPi433utils() {
	git clone git://git.drogon.net/wiringPi
	git clone git://github.com/ninjablocks/433Utils.git
	sudo wiringPi/build
	sudo 433Kit/RPi_utils/make
}
function create_Dir() {
if ! [ -d $1 ] ; then
	echo "$1 not found. Will create it now..."
	mkdir $1
	if ! [ $? = 0] ; then
		echo "Error with creating $1. Trying it again wit sudo..."
		sudo mkdir $1
		if ! [ $? = 0] ; then
		echo "Error with creating $1 again."
		fi
	fi
fi
}
function give_root() {
	sudo usermod -aG sudo $1
	sudo cat << EOF >> /etc/sudoers
$1 ALL=(ALL) NOPASSWD: ALL
EOF
}
###########################################################################################
###########################################################################################
echo $myIntention
#update and uprade your Raspbian with apt-get
updateUpgrade
#create ~/bin if not existing and changing to it
create_Dir ~/bin && cd ~/bin/
#install git
package_install git
#download and compile packages
install_wiringPi433utils
#give 'www-data' root-rights
give_root www-data
#install etherwake
package_install etherwake
#end
echo "Please report bugs or request features on $myHome."
exit 0
