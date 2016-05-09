#!/bin/bash

#: xkcd downloader, which remains the mouse-hover comment
#from page 21, Post your handy self made command line utilities by Barracuda
TMP='/tmp/xkcd.cURL.tmp'
XKCD='http://www.xkcd.com'
DIR="$HOME/Pictures/xkcd"   #Anywhere you want to store your xkcd comics. Create this by hand.
LOG='_xkcd.last'                 #This is put inside $DIR.
if [ -e $DIR ];then
	echo "Going to $DIR"
	cd "$DIR" || exit 1
else
	echo "Creating $DIR"
	mkdir -p $DIR
	echo "Going to $DIR"
	cd "$DIR" || exit 1
fi

function grab()
{
idx=$1
url="$XKCD/$idx/" ; prev=$((idx-1)) ; next=$((idx+1))
curl -s "$url" -o "$TMP"
image=$(grep '<img src="http://imgs.xkcd.com/comics/' "$TMP" | sed 's|.*img src="\([^"]*\)".*|\1|')
name="$idx.${image/http:\/\/imgs.xkcd.com\/comics\//}"
alt=$(grep '<img src="http://imgs.xkcd.com/comics/' "$TMP" | sed 's|.*" alt="\(.*\)".*|\1|')
echo "Checking if file already exists."
if [ -f $name ];then
	echo "You already have $idx"
else
	wget -O "$name" "$image" #or wget
fi
if [ -f $idx.html ];then
	echo "$idx already has a page."
else
	echo "Creating minimal page for $idx..."
	echo '<html>' > $idx.html
	echo '<div align=center>'"$alt"'</div>' >> $idx.html
	echo '<div align=left>' >> $idx.html
	echo '<li><a href="'"$prev"'.html">&lt; Prev</a></li>' >> $idx.html
	echo '</div>' >> $idx.html
	echo '<div align=center>' >> $idx.html
	grep '<img src="http://imgs.xkcd.com/comics/' "$TMP" | sed 's|http://imgs.xkcd.com/comics/|'$idx'.|' >> $idx.html
	echo '</div>' >> $idx.html
	echo '<div align=right>' >> $idx.html
	echo '<li><a href="'"$next"'.html">Next &gt;</a></li>' >> $idx.html
	echo '</div>' >> $idx.html
	echo '</html>' >> $idx.html
	echo "Done creating minimal page for $idx..."
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
    latest=$(curl -s "$XKCD" | grep 'Permanent link to this comic' |
             sed s'|.*xkcd.com/\(.*\)/<.*|\1|')
    for ((idx=last;idx<=latest;idx++)) ; do
        [ -f $idx.html ] || grab $idx
    done
    echo $((latest+1)) > "$LOG"
    echo "==> Updated $last ~ $latest. Enjoy :)"
fi
