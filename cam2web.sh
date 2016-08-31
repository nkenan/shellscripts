#!/bin/bash
### DESCRIPTION: Capturing images or videos from webcam and sending them to a webserver
### To do: video capturing, implenting motion or other tools; to be tested with other os than raspbian
### please report bugs to http://github.com/NazimKenan/shellscripts/cam2web.sh

myName="cam2web"
myVersion="0.1a"
myHome="http://github.com/NazimKenan/shellscripts/cam2web.sh"
localPath="/home/pi/bin/$myName" #please provide explicit path

#reading config file or creating one

################################################################################################
################################ FUNCTIONS #####################################################
################################################################################################

#reading configuration file
function get_config() {
	if [[ ! -f $localPath/$myName.config ]] ; then
		echo "Creating random configuration..."
		cat<<EOF> $myName.config
#!/bin/bash
# Description: configuration file for cam2web.sh - delete this file and cam2web will generate
# new configuration file with next run

# where to stream to - on localhost or different server? Besides that backup place to choose! In both cases
# "0" for no , "1" for yes - please consider your device running out of storage if you do not clean your hd regulary
server=1
localhost=1

localhostBackup=1
serverBackup=0

#server credentials - if streams are sent to another webserver
serverAddress="your.server.com"
serverPath="/var/www/html/cam2web"
serverUser="yourUsername"
serverPassword="yourPassword"

#own webserver credentials - if streams are published on localhost webserver
localhostDirectory="/var/www/html/cam2web"

#characteristics of captures to make and webpage to create
filename="image.jpeg"
format="jpeg"
resolution="640x480"
loopDelayForCamera="5" #seconds to wait before starting next capture-loop
webpageFile="index.html"

EOF
else
	echo "Existing configuration found."
fi
	source $localPath/$myName.config
}

#checking whether tools are installed and installs them
function update_upgrade() {
	read -p "Do you want to update and upgrade your operating system now? Type yes: " yes
	if [[ $yes = 'yes' ]] ; then
			sudo apt-get update && sudo apt-get -y upgrade
	else
		echo "Continuing without update or upgrade..."
	fi
}

function package_exists() {
    dpkg -s $1 &> /dev/null
}

function package_install() {
	if ! package_exists $1 ; then
	echo "$1 could not be found on your system. Download and installation will begin now."
	updateUpgrade
	sudo apt-get install $1
else
	echo "$1 is already installed."
fi
}

#upload function
function upload_this() {
	if [[ $server == "1" ]] ; then
		echo "server is set to 1" #debug 
		scp $1 $serverUser@$serverAddress:$serverPath/$(basename $1) &
	fi
	if [[ $localhost == "1" ]] ; then
		echo "localhost is set to 1" #debug
		cp $1 $localhostDirectory
	fi
}

#to create backups on localhost or different server
function backup_this() {
	if [[ $localhostBackup == "1" ]] ; then 
		echo "localhostBackup is set to 1" #debug 
		if [ ! -d $localPath/backup ] ; then
			echo "localhostBackup/backup does not exist" #debug 
			mkdir $localPath/backup
			echo "Created new directory for backup on localhost"
		else
		 echo "Found existing directory for backup on localhost"
		fi
		cp $1 $localPath/backup/$(date +"%Y-%m-%d-%H:%M:%S")-$(basename $1)
	fi
	if [[ $serverBackup == "1" ]] ; then 
		echo "Server backup does not work right now."
	fi
}

#capturing and uploading pictures
function stream_this() {
	#loop: creating and uploading pictures
	while true
	do
		streamer -f $format -o $localPath/$filename -s $resolution
		upload_this $localPath/$filename
		backup_this $localPath/$filename
		if [[ $loopDelayForCamera != 0 ]] ; then
			echo "Waiting $loopDelayForCamera seconds for next capture."
			sleep $loopDelayForCamera
		fi
	done
}

#to create a lean webpage
function create_webpage() {
cat<<EOF> $1
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8>
<meta name=viewport content=width=device-width,initial-scale=1>
<link rel=stylesheet href=https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css integrity=sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7 crossorigin=anonymous>
<title>$myName</title>
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
	<div class="col-xs-12">started last: $(date +"%d.%m.%Y@%H:%M:%S") &#183; $myName $myVersion &#183; <a href="$myHome" target="_blank">github</a></div>
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
	FREEDOM FOR EDWARD SNOWDEN.
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
create_webpage $localPath/$webpageFile && upload_this $localPath/$webpageFile #once at startup of script
stream_this #looping

#end of script
exit 0
