#!/bin/bash

#: PFSC downloader, which remains the mouse-hover comment
#from page 21, Post your handy self made command line utilities by Barracuda. Modded for Pictures
#For Sad Children 
TMP='/tmp/pfsc.cURL.tmp'
PFSC="http://www.picturesforsadchildren.com/"
DIR="$HOME/Pictures/pfsc"
LOG='_pfsc.last'                 #This is put inside $DIR.
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
url="$PFSC/index.php?comicID=$idx" ; prev=$((idx-1)) ; next=$((idx+1))
echo "Getting comic $idx"
curl -s "$url" -o "$TMP"
image=$(grep '<img src="http://www.picturesforsadchildren.com/comics/' "$TMP"|sed 's|.*img src="\([^"]*\)".*|\1|'|head -n 1|cut -c -57)
ext=$(echo $image|tail -c 4)
alt=$(grep '<img src="http://www.picturesforsadchildren.com/comics/' "/tmp/pfsc.cURL.tmp" | sed 's|.*" title="\(.*\)".*|\1|'|head -n 1)
name="$idx.${alt%%'" border="0'}.$ext"
echo "Creating filename for comic $idx...it is $name."
if [ -f $name ];then
	echo "You already have $idx"
else
	wget -O "$name" "$image"
fi
if [ -f $idx.html ];then
	echo "$idx already has a page."
else
echo "Creating webpage for comic $idx...it is $name."
echo '<html>' > $idx.html
echo '<div align=center>'"${alt%%'" border="0'}"'</div>' >> $idx.html
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
    latest=$(($(curl -s "$PFSC"|grep comicID|head -n 1|grep -E comicID=[0-9]+ -o -m 1|head -n 1|sed s/"comicID="//)+1))
    #skwee=$(($(date +%m%d%Y%k)-27))
    for ((idx=last;idx<=latest;idx++)) ; do
        [ -f $idx.html ] || grab $idx
    done
    echo $((latest)) > "$LOG"
    echo "==> Updated $last ~ $latest. Enjoy :)"
fi
