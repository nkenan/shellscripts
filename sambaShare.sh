#!/bin/bash
myName="sambaShare"
myIntention="To quickliy install samba-server and configure shares"
myHome="https://www.github.com/NazimKenan"
################################################################################
################################################################################
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
function create_share() {
	sudo cat << EOF >> /etc/samba/smb.conf
	[TestFreigabe]
	path = /media/usbstick
	writeable = yes
	guest ok  = no
	EOF
}
function first_setup() {
	sudo cat << EOF >> /etc/samba/smb.conf
	security = user
	EOF
}
function password() {
	read -p "Create a password? Type the user's name or press 'Enter' to continue with password: " user
	if ! [ -z $user ] ; then
 		smbpasswd -a $user
	else
 		echo "Continuing with password for user..."
	fi
}
################################################################################
################################################################################
package_install samba
package_install samba-common-bin
first_setup
password
create_share
echo "Please request features or report bugs on $myHome"
exit 0
