#!/bin/bash
### DESCRIPTION: Capturing images or videos from webcam and sending them to a webserver
### To do: video capturing, implenting motion or other tools; to be tested with other os than raspbian
### please report bugs to http://github.com/NazimKenan/shellscripts/cam2browser.sh
### for start on boot of pi add following line to your rc.local (sudo nano /etc/rc.local):
### su pi -c '/home/pi/bin/cam2browser/cam2browser.sh 2> /home/pi/bin/cam2browser/error.log &'

myName="cam2browser"
myVersion="0.1a"
myIntention="Capturing images or videos from webcam and sending them to a webserver"
myHome="http://github.com/NazimKenan/shellscripts/cam2browser.sh"
myLocalPath="/home/pi/bin/$myName" #please provide explicit path to this sh-file's
#directory (not ~/.. or symbolic links) <-- very important!

################################################################################################
################################ FUNCTIONS #####################################################
################################################################################################

#reading configuration file
function get_config() {
	if [[ ! -f $myLocalPath/$myName.config ]] ; then
		echo "Creating random configuration..."
cat << EOF > $myLocalPath/$myName.config
#!/bin/bash
# Description: configuration file for cam2browser.sh - delete this file and cam2browser will generate
# new configuration file with next run

#server credentials - use when streams are sent to another webserver - never leave on unsecured devices - can lead to security issues
server="1" #switch to publish on different server - 1 for publishing, 0 for not publishing
serverAddress="yourServer.com"
serverDirectory="/var/www/html/$myName"
serverUser="yourUsername"
serverPassword="yourPassword goes here - please be aware of everyone able to read it when accessing your device"
serverBackup="0" #shall backups be made on server? 1 for yes, 0 for no
serverBackupDir="/var/www/virtual/nzm7591/html/$myName/backup"


#own webserver credentials - use when streams are published on localhost webserver - never leave on unsecured devices - can lead to security issues
localhost="1" #switch to publish on localhost - 1 for publishing, 0 for not publishing
localhostDirectory="/var/www/html/$myName"
localhostBackup="0" #shall backups be made on localhost? 1 for yes, 0 for no
localhostBackupDir="/var/www/html/$myName/backup"

#characteristics of captures to make and webpage to create
filename="image.jpeg"
format="jpeg"
#resolution="1280x720" #depends on your camera; higher resolution may lead to performance issues
resolution="640" #depends on your camera; higher resolution may lead to performance issues
loopDelayForCamera="3" #seconds to wait before starting next capture-loop
webpageFile="index.html"
EOF

else
	echo "Existing configuration found."
fi
	source $myLocalPath/$myName.config
}

#trying to update your operating system
function update_upgrade() {
	read -p "Do you want to update and upgrade your operating system now? Type yes: " yes
	if [[ $yes = 'yes' ]] ; then
			sudo apt-get update && sudo apt-get -y upgrade
	else
		echo "Continuing without update or upgrade..."
	fi
}

#installs missing packages if needed
function package_install() {
	function package_exists() {
    	dpkg -s $1 &> /dev/null
	}
	if ! package_exists $1 ; then
		echo "$1 could not be found on your system. Download and installation will begin now."
		updateUpgrade
		sudo apt-get install $1
	else
		echo "$1 is already installed."
	fi
}

#upload function for files for both localhost and server
function upload_this() {
	if [[ $localhost == "1" ]] ; then
		create_dir $localhostDirectory localhost #only if directory doesn't exist
		cp $1 $localhostDirectory/$(basename $1)
	fi
	if [[ $server == "1" ]] ; then
		create_dir $serverDirectory server #only if directory doesn't exist
		scp $1 $serverUser@$serverAddress:$serverDirectory/$(basename $1)
	fi
}

#to create backups both on localhost or a different server
function backup_this() {
	if [[ $localhostBackup == "1" ]] ; then 
		create_dir $localhostBackupDir localhost
		cp $1 $localhostBackupDir/$(date +"%Y-%m-%d-%H:%M:%S")-$(basename $1)
	fi
	if [[ $serverBackup == "1" ]] ; then
		create_dir $serverBackupDir server
		scp $1 $serverUser@$serverAddress:$serverBackupDir/$(date +"%Y-%m-%d-%H:%M:%S")-$(basename $1)
	fi
}

#creating missing directories on localhost and server
directory_checked="0"
function create_dir() {
	if [ $directory_checked != "1" ] ; then
		echo "Checking directories for the first time."
		if [ $2 == "localhost" ] && [ ! -d $1 ] ; then
			mkdir $1
		fi
		if [ $2 == "server" ] && ( ssh $serverUser@$serverAddress "[ ! -d $1 ]" ) ; then
			ssh $serverUser@$serverAddress "mkdir $1"
		fi
		directory_checked="1"
	else
		echo "Directories were checked already." #debug
	fi
}

#capturing and uploading pictures
function stream_this() {
	#loop: creating and uploading pictures
	while true
	do
		streamer -f $format -o $myLocalPath/$filename -s $resolution
		upload_this $myLocalPath/$filename
		backup_this $myLocalPath/$filename
		if [[ $loopDelayForCamera != 0 ]] ; then
			echo "Waiting $loopDelayForCamera seconds for next capture."
			sleep $loopDelayForCamera
		fi
	done
}

#to create a lean webpage
function create_webpage() {
cat<<EOF > $1
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8>
<meta name=viewport content=width=device-width,initial-scale=1>
<link rel=stylesheet href=https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css integrity=sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7 crossorigin=anonymous>
<title>$myName &#8226; $myIntention</title>
<style>
body { margin:5px;
font-family: Verdana; }
</style>
<body>
<div class="container">
	<content>
	<div class="row">
	<div class="col-xs-12"><img id="streamPicture" src="$filename" width="100%"/></div>
	</div>
	</content>
	<footer>
	<div class="row">
	<div class="col-xs-12"><a href="$myHome" target="_blank">$myName</a> $myVersion &#8226; started last: $(date +"%d.%m.%Y@%H:%M:%S") &#8226; <a href="http://wikipedia.org/wiki/Pygoscelis" target="_blank">Pygoscelis?</a></div>
	</div>
	</footer>
</div>
</body>
<script>
window.onload = function() {
    var image = document.getElementById("streamPicture");
    function updateImage() {
        image.src = image.src.split("?")[0] + "?" + new Date().getTime();
    }
    setInterval(updateImage, $loopDelayForCamera$(echo 000));
}</script>
<script src=https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js></script>
<script src=js/bootstrap.min.js></script>
<!--
	EAT THIS NSA: FREEDOM FOR EDWARD SNOWDEN!
-->
<html>
EOF
}

################################################################################################
############################ END  OF FUNCTIONS   ###############################################
################################################################################################

#start of script
get_config
package_install streamer #only if needed
create_webpage $myLocalPath/$webpageFile && upload_this $myLocalPath/$webpageFile #once at startup of script
stream_this #looping

#end of script
exit 0
