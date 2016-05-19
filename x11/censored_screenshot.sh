#!/bin/bash

filename="/tmp/$(date +%F-%H%M%S).png"
sleep "${1:-0}"

if [ "$3" = "yes" ];then
	maim --showcursor "$filename"
else
	maim "$filename"
fi

if [ "$2" = "yes" ];then
	convert "$filename" \
	    -fill '#000f' -draw 'rectangle 168,1044,270,1076' \
	    -font 'AveriaSerif-Regular' -pointsize 20 \
	    -fill red -annotate +184+1067 'Sigils' \
	    "$filename"
fi
notify-send "Screenshot saved" "$filename"
