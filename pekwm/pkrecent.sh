#!/bin/sh

echo "Dynamic {"
files=$(
cat ~/.recently-used.xbel | grep file:///  | tail -n30 |  cut -d "\"" -f 2 | tac | while read line; 
do  
file=$(echo "$line")
name=$(echo -en "$file" | sed 's,.*/,,' | sed 's/%20/ /g')
echo "Entry = \"$name\" { Actions =\"Exec exo-open $line &\" }"
done);
echo "$files"
echo "Separator {}"
echo "Entry = \"Clear Recent Documents\" { Actions =\"Exec rm ~/.recently-used.xbel &\" }"
echo "}"
