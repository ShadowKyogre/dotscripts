#!/bin/sh

here="$(ls -d -1 /usr/share/xsessions/* 2> /dev/null;ls -d -1 /etc/X11/sessions/* 2> /dev/null)"

wmdisplist=$(echo "$here"|while read line;
do
file="$(cat $line)"
name=$(echo "$file"|grep "Name="|sed 's/Name=//')
if test -n "$name" ;then
	echo "\"$name\""
fi
done|sort -u|uniq|tr '\n' ' '|sed 's/[ \t]*$//')

wmbinlist=$(echo "$here"|while read line;
do
file="$(cat $line)"
exec="$(echo "$file"|grep "^Exec="|sed 's/Exec=//')"
if test -n "$exec" ;then
	echo "\"$exec\""
else
continue;
fi
done|sort -u|uniq|tr '\n' ' '|sed 's/[ \t]*$//')


echo "wmbinlist=(${wmbinlist})"
echo "wmdisplist=(${wmdisplist})"
