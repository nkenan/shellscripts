#!/bin/bash

#to do: add external html-template
#to do: store server-credentials outside of this script or by arguments
#to do: check for streamer and curl and install them if not yet

myName="pictureStreamer"
myVersion="0.0.9b"
myIntention="Capturing pictures with a Raspberry Pi and streaming them to the web with GNU/Linux"
myHome="http://github.com/NazimKenan"

#user and server
destinationServer="sftp://your.server.com"
user="yourUsername"
password="password"
pathOnServer=":/var/www/virtual/path/to/your/foulder"

#characteristics of webpage
webpageFile="index.html"
webpageImageWidth="100%"
webpageImageRefreshRate="500" #milliseconds

#characteristics of pictures to shoot
pictureFile="image.jpeg"
pictureFormat="jpeg"
pictureResolution="1280x720"
loopDelayForCamera="1" #seconds to wait before capturing next picture

#creating webpage
cat << EOF > $webpageFile
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
	<div class="col-xs-12">$(date +"%d.%m.%Y") &#183; $myName $myVersion &#183; $myIntention &#183; <a href="$myHome" target="_blank">report bugs</a></div>
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
    setInterval(updateImage, $webpageImageRefreshRate);
}</script>
<script src=https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js></script>
<script src=js/bootstrap.min.js></script>
<html>
EOF

#uploading webpage
curl -k -u $user:$password -T $webpageFile $destinationServer$pathOnServer

#loop: creating and uploading pictures
while true
do
streamer -f $pictureFormat -s $pictureResolution -o $pictureFile
curl -k -u $user:$password -T $pictureFile $destinationServer$pathOnServer
sleep $loopDelayForCamera
done

#end of script
exit 0

