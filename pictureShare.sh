#!/bin/bash
myName="pictureShare"
myVersion="0.0.9b"
myPath="/path/to/pictureShare.sh" #should be located in DocumentRoot
mediaPath="media" #create directory 'media' if it doesn't exist

pictureUrl="$1"
pictureFile="$2-$(date +"%Y-%m-%d-%H:%M:%S").jpg"
pictureDescription="$3"
descriptionFile="$2-$(date +"%Y-%m-%d-%H:%M:%S").txt"

curl -o "$mediaPath/$pictureFile" "$pictureUrl"

echo "$pictureDescription" >> "${mediaPath}/${descriptionFile}"

text=$(cat ${mediaPath}/${descriptionFile})
cat << EOF > index.php
<?php if (isset(\$_POST["Url"])) {
        \$pictureUrl = \$_POST["Url"];
        \$pictureName = \$_POST["Name"];
        \$pictureDescription = \$_POST["Description"];
        exec('$myPath "'.\$pictureUrl.'" "'.\$pictureName.'" "'.\$pictureDescription.'"');


} ?>
<!DOCTYPE html>
<head>
        <meta charset=utf-8>
        <meta name=viewport content=width=device-width,initial-scale=1>
        <title>$2 - generated with $myName</title>
        <link rel=stylesheet href=https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css integrity=sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7 crossorigin=anonymous>
        <style>
                body { background-color: #bbb; }
                footer { font-size: -2pt; font-style: italic;}
        </style>
</head>
<body>
        <p>
        <div class=container>
        <content>

        <div class="row">
                <div class="col-xs-12"><h2><a href="">$2</a></h2></div>
        </div>
        <div class="row">
                <div class="col-xs-12">
                        <img src="media/$pictureFile" width="100%"/>
                </div>
        </div>
        <div class="row">
                <div class="col-xs-6 text-center">
                        <p><em>Description</em>: $text<br/></p>
                </div>
                <div class="col-xs-6 text-center">
                        <p><em>Filename</em>: $mediaPath/$pictureFile</p>
                </div>
        </div>
        </content>

        <div class="row">
                <div class="col-xs-12">
                        <h3>Share interesting pictures</h3>
                        <p>$myName is an open website for sharing pictures. Just provide an url, a name and a short description and press &quot;Submit&quot;. Or explore other <a href="$mediaPath/" target="_self">pictures</a>.</p>
                </div>
        </div>
        <div class="row">
                <div class="col-xs-12">
                        <form action"" method="post">
                                <input type="text" name="Url" placeholder="Url" />
                                <input type="text" name="Name" placeholder="Name (only one word)" />
                                <input type="text" name="Description" placeholder="Description" />
                                <input type="submit" value="Submit">
                        </form>
                </div>
        </div>
        <br/>
        <footer>
                <aside>
                        <div class="row">
                <div class="col-xs-12">
                        <p>$myName $myVersion &#183; please report bugs on <a href="https://www.github.com/NazimKenan/">GitHub</a></p>
                </div>
        </div>
                </aside>
        </footer>
        </div>
        <script src=https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js></script>
        <script src=js/bootstrap.min.js></script>
        </p>
</body>
</html>
<!-- Freedom for Edward Snowden! -->
<!-- Please consider to eat less meat and please begin to care about our planet.-->
<!-- this tool was written by Nazim Kenan - please report bugs on https://github.com/NazimKenan -->
EOF
