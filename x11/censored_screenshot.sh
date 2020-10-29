#!/bin/bash

filename="/tmp/$(date +%F-%H%M%S).png"
sleep "${1:-0}"

if [ "$3" = "yes" ];then
	maim "$filename"
else
	maim --hidecursor "$filename"
fi

if [ "$2" = "yes" ];then
	convert "$filename" \
#	    -fill '#000f' -draw 'rectangle 162,1044,265,1076' \
#	    -font 'AveriaSerif-Regular' -pointsize 20 \
#	    -fill red -annotate +184+1067 'Sigils' \
#	    "$filename"
	convert "$filename" \
	    -fill '#000f' -draw 'rectangle 162,2124,265,2156' \
	    -font 'AveriaSerif-Regular' -pointsize 20 \
	    -fill red -annotate +184+2147 'Sigils' \
	    "$filename"
fi
notify-send "Screenshot saved" "$filename"
