#!/bin/bash
myName="archLinuxOpenSSHforLiveImage"
myVersion="0.1b"
myHome="http://www.github.com/NazimKenan/"
myIntention="Fast and lean. Enabling openSSH for archlinux' Live-Image."
echo "Begin of setup. ($myName)"
#Typing password. 'root' needs one for ssh-login.
read -p "Do you want to set a password? Type yes or anything else: " yes
if [ $yes == "yes" ] ; then
	passwd
else
	echo "Continuing without setting password."
fi
#Backup of old sshd_config.bak
read -p "Do you want to backup your current sshd_config? Type yes or anything else: " yes
if [ $yes == "yes" ] ; then
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak$(date +"%Y-%m-%d@%H:%M:%S")
else
	echo "Continuing without backup."
fi
#'PermitRootLogin yes' to '/etc/ssh/sshd_config'
echo "Adding 'PermitRootLogin yes' to your '/etc/ssh/sshd_config'..."
cat<<EOF>>/etc/ssh/sshd_config
PermitRootLogin yes
EOF
echo "Restarting openSSH daemon..."
systemctl restart sshd
echo "End of setup. ($myName)"
exit 0
