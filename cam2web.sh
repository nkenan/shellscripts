#!/bin/bash
### DESCRIPTION: Capturing images or videos from webcam and sending them to a webserver
### Setup: place it in ~/bin/cam2web and add entry to etc/rc.local like this: su pi -c 'directoryOfcam2Web/cam2web.sh 2> directoryOfcam2web/error.log &'
### Setup: please always use explicit paths, not ~ to obey path problems with rc.local
### To do: repair package_install, add functionality for arguments, video capturing
myName="cam2web"
myVersion="0.1a"
myHome="http://github.com/NazimKenan/shellscripts/cam2web.sh"
localPath="/home/pi/bin/cam2web" #must be specified when using a raspberry pi due to rc.local being executed by root

#checking whether tools are installed
function updateUpgrade() {
	read -p "Do you want to update and upgrade by apt-get? Type yes: " yes
	if [[ $yes = 'yes' ]] ; then
			sudo apt-get update && sudo apt-get -y upgrade
	else
		echo "Continuing without 'sudo apt-get update && apt-get -y upgrade'..."
	fi
}

function package_exists() {
    return dpkg -l "$1" &> /dev/null
}

function package_install() {
	if ! package_exists $1 ; then
	echo "$1 could not be found. Download and installation will begin now."
	updateUpgrade
	sudo apt-get install $1
else
	echo "$1 is already installed."
fi
}

#user and server
destinationServer="myWebserverDomain.de"
user="yourUsername"
password="YourPassword"
pathOnServer="/var/www/html/cam2web" # visit http://myWebserverDomain.de/cam2web with your browser

#characteristics of pictures to shoot
pictureFile="image.jpeg"
pictureFormat="jpeg"
pictureResolution="640x460"
loopDelayForCamera="5" #seconds to wait before starting next capture-loop

#characteristics of webpage
webpageFile="index.html"
webpageImageWidth="100%"

#creating webpage
cat << EOF > $localPath/$webpageFile
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
	<div class="col-xs-12"><img id="streamPicture" src="$pictureFile" width="$webpageImageWidth"/></div>
	</div>
	</content>
	<footer>
	<div class="row">
	<div class="col-xs-12">$(date +"%d.%m.%Y") &#183; $myName $myVersion &#183; <a href="$myHome" target="_blank">github</a></div>
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
<html>
EOF

#uploading webpage once at start
scp $localPath/$webpageFile $user@$destinationServer:$pathOnServer/$webpageFile &

#loop: creating and uploading pictures
while true
do
streamer -f $pictureFormat -o $localPath/$pictureFile -s $pictureResolution
cp $localPath/$pictureFile $localPath/$(date +"%Y-%m-%d-%H:%M:%S").jpeg
scp $localPath/$pictureFile $user@$destinationServer:$pathOnServer/$pictureFile &
sleep $loopDelayForCamera
done

#end of script
exit 0
