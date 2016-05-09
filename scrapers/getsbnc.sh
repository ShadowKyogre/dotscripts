#!/bin/bash

#: Subnormality! downloader, which remains the mouse-hover comment
#from page 21, Post your handy self made command line utilities by Barracuda. Modded for Subnormality
TMP='/tmp/SBNC.cURL.tmp'
SBNC="http://www.viruscomix.com"
DIR="$HOME/Pictures/snbc"
LOG='_SBNC.last'                 #This is put inside $DIR.
if [ -e $DIR ];then
#Checks if directory exists
	echo "Going to $DIR"
	cd "$DIR" || exit 1
else
#Makes directory if it doesn't
	echo "Creating $DIR"
	mkdir -p $DIR
	echo "Going to $DIR"
	cd "$DIR" || exit 1
fi

function grab()
{
idx=$1
url="$SBNC/page$(($idx + 323)).html" ; prev=$((idx-1)) ; next=$((idx+1))
echo "Getting comic $idx"
curl -s "$url" -o "$TMP"
image=$(grep -E 'subnext\.gif"></a>(<br>)*<img style=".*" alt="" title=".*" src=".*"><br>' $TMP -o|sed 's|<br><a.*||;s|<br>||g;s|subnext.gif"></a><img .* alt=""||;s|title=".*" src="||;s|">||;s| ||')
#src="subnext.gif"></a><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><img style="width: 857px; height: 4473px; position: absolute; z-index: 1; top: 206px; left: 15px;" alt="" title="special thanks to &quot;Bambi Meets Godzilla&quot; for the end bit there" src="monstrepancies.jpg"><br>
#grep -E 'subnext\.gif"></a>(<br>)*<img style=".*" alt="" title=".*" src=".*"><br>' /tmp/page528.html -o|sed 's|<br><a.*||;s|<br>||g;s|subnext.gif"></a><img .* alt="" ||'
#grabs img & title
alt=$(grep -E 'subnext\.gif"></a>(<br>)*<img style=".*" alt="" title=".*" src=".*"><br>' $TMP -o|sed 's|<br><a.*||;s|<br>||g;s|subnext.gif"></a><img .* alt="" ||;s|src=".*">||;s|title="||;s|"||')
name="$idx.$image"
echo "Creating filename for comic $idx...it is $name."
if [ -f $name ];then
	echo "You already have $idx"
else
	wget -O "$name" "$SNBC/$image"
fi
if [ -f $idx.html ];then
	echo "$idx already has a page."
else
echo "Creating webpage for comic $idx...it is $name."
echo '<html>' > $idx.html
echo '<div align=center>'"${image%.jpg}"'</div>' >> $idx.html
echo '<div align=center>'"$alt"'</div>' >> $idx.html
echo '<div align=left>' >> $idx.html
echo '<li><a href="'"$prev"'.html">&lt; Prev</a></li>' >> $idx.html
echo '</div>' >> $idx.html
echo '<div align=center>' >> $idx.html
echo "<img src=\"$name\" border="0" />" >> $idx.html
echo '</div>' >> $idx.html
echo '<div align=right>' >> $idx.html
echo '<li><a href="'"$next"'.html">Next &gt;</a></li>' >> $idx.html
echo '</div>' >> $idx.html
echo '</html>' >> $idx.html
fi
}

if [ "$1" == '-v' ] ; then
    firefox file://"$DIR"/${2:-1}.html
    exit
elif [ "$#" != '0' ] ; then
    for i in $@ ; do
        grab $i
    done
else
    [ -f "$LOG" ] && last=$(cat "$LOG") || last='1'
    latest=$(($(curl -s http://viruscomix.com/subnormality.html|grep subback.gif|sed 's|"><img.*||;s|</a><a href="page||;s|\.html||')-323))
    for ((idx=last;idx<=latest;idx++)) ; do
        [ -f $idx.html ] || grab $idx
    done
    echo $((latest+1)) > "$LOG"
    echo "==> Updated $last ~ $latest. Enjoy :)"
fi
