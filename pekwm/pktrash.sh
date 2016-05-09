#!/bin/sh

if [ "$1" == "" ]; then
	trash=$HOME/.local/share/Trash/files
else
	trash="$1"
fi
echo "Dynamic {"
files=$(
ls -1 $trash | while read line; 
do  
file=$(echo "$line")
name=$(echo -en "$file" | sed 's,.*/,,' | sed 's/%20/ /g')
echo "Submenu = \"$name\" {"
	echo "Entry = \"Open this Item\" { Actions =\"Exec exo-open \\\"$trash/$line\\\" &\" }"
	echo "Entry = \"Delete this Item\" { Actions =\"Exec rm -f \\\"$trash/$line\\\" &\" }"
echo "}"
done);
echo "Entry = \"Open Trash - $(ls -h -s $trash|head -n 1|sed 's/total/Size:/')\" { Actions =\"Exec exo-open $trash &\" }"
echo "Entry = \"Empty Trash - $(ls -h -s $trash|head -n 1|sed 's/total/Frees:/')\" { Actions =\"Exec rm -rf $trash/* &\" }"
echo "Separator {}"
echo "$files"
echo "}"
