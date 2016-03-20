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
		echo "$1 not found. Start to download and install now..."
		sudo apt-get install $1
	else
		echo "$1 already installed."
	fi
}
function create_share() {
	echo "Creating a share. Please provide information..."
	read -p "Type path of directory to share: " path
	read -p "Type name of share: " name
	sudo /bin/su -c "cat << EOF >> /etc/samba/smb.conf
[$name]
path = $path
writeable = yes
guest ok  = no
EOF"
	echo "Please check owenership of "$path" if you experience permission problems. Maybe you must chown it."
	echo "$1 shared as $name on $(hostname): $(hostname)/$name"
}
function first_setup() {
	sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
	sudo /bin/su -c "echo 'security = user' >> /etc/samba/smb.conf"
}
function password() {
	read -p "Create a password? Type the user's name or press 'Enter' to continue without password: " user
	if ! [ -z $user ] ; then
		sudo smbpasswd -a $user
	else
		echo "Continuing with password for user..."
	fi
}
function service_restart() {
	read -p "Restart $1? Type yes: " yes
	if [ $yes = 'yes' ] ; then
		echo "Restarting $1 now..."
		sudo systemctl restart $1
		if [ $? = 0 ] ; then
			echo "Successfully restarted $1."
		else
			echo "Failed to restart $1."
		fi
	fi
}
################################################################################
################################################################################
package_install samba
package_install samba-common-bin
first_setup
password
create_share
service_restart smbd.service
echo "Please request features or report bugs on $myHome"
exit 0
