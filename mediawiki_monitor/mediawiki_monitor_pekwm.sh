#!/bin/sh
#TODO: Fix for wikipedia
#regex idea so far:
#$mainurl=$(echo $1|grep 'http://[^/]*' -o)
#not sure if you can have empty action items
page=$(curl -s "$1/index.php?title=Special:RecentChanges&limit=${2:-50}")
wiki=$(echo "$page"|grep -E '<title>.*</title>'|sed 's|Recent changes - ||;s|<title>||;s|</title>||;s|^[ \t]*||g')
recent=$(echo "$page"|awk 'BEGIN {x=0}
{
if ($0~"<ul class=\"special\">") {x=1}
if (x==1) {print $0}
if ($0~"<div class=\"printfooter\">") {x=0}
}'|sed 's/<ul class="special">//g;s|<div class="printfooter">||;s|</ul>||g;/^$/d')
echo "Dynamic {"
echo "Entry = \"Visit $wiki\" { Actions = \"Exec ${3:-firefox} $1 &\" }"
echo "Entry = \"Check $wiki's uploads\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/upload &\" }"
echo "Entry = \"Check $wiki's blocks\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/block &\" }"
echo "Entry = \"Check $wiki's protections\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/protect &\" }"
echo "Entry = \"Check $wiki's new users\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/newusers &\" }"
echo "Entry = \"Check $wiki's patrols\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/patrol &\" }"
echo "Entry = \"Check $wiki's deletions\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/delete &\" }"
echo "Entry = \"Check $wiki's moves\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/move &\" }"
echo "Entry = \"Check $wiki's user renames\" { Actions = \"Exec ${3:-firefox} $1/Special:Log/renameuser &\" }"
echo "Separator {}"
menu=$(echo "$recent"| while read line; 
do  
diff=$(echo "$line"|grep -E 'diff=[0-9]+' -o|sed 's|diff=||')
curid=$(echo "$line"|grep -E 'curid=[0-9]+' -m 1 -o|sed 's|curid=||'|head -n 1)
oldid=$(echo "$line"|grep -E 'oldid=[0-9]+' -m 1 -o|sed 's|oldid=||')
echo "$curid"
if [ "$curid" != "" ];then
	artc=$(echo "$line"|grep -E '  <a href=".*" title=".*">.*</a>‎;(?:&#32;| )?' -o)
	time=$(echo "$line"|grep -E '[0-9]{2}:[0-9]{2}' -o)
	title=$(echo "$artc"|grep -E '>.*</a>' -o|sed 's/>//g;s/<\/a//g')
	link=$(echo "$artc"|grep -E 'href=".*"' -o|sed 's/href="//g;s/"//g;s/ title=.*//g;s|^/.*/||')
	comment=$(echo "$line"|grep -E '<span class="comment">\(.*\)</span>' -o|sed 's/<\/span>//g;s/<span class="comment">//g;s/<span class="autocomment">//g;s/<a href=".*" title=".*">→<\/a>/→ /g;s/&#32\;//g;s|<|\&lt\;|g;s|>|\&gt\;|g'|head -c 30)
	statsuser=$(echo "$line"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)</.*>.*<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a> <' -o)
	stats=$(echo "$statsuser"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)<' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	user=$(echo "$statsuser"|grep -E '<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a>' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	userurl=$(echo "$statsuser"|grep -E 'href=".*/(index.php\?title=)?User:.*(&amp;.*)?"( title| class)' -o|sed 's/href="//g;s/"//g;s/ title=.* class//g;s/ class=.* title//g'|grep -E '(index.php\?title=|/)?User:.*(&amp;action.*)?' -o|sed 's/User://g;s/index.php\?title=//g;s/\///g;s/&amp;action.*//g;s/ title=.* class//g;s/ class=.* title//g;s|^index.php?title=||')
	echo "	Submenu = \"$time @ $title by $user $stats\" {"
	echo "		Entry = \"${comment:-"No comment on this change."}\" {}"
	echo "		Entry = \"Visit $title\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=$link &\" }"
	if [ "$diff" != "" ];then
		echo "		Entry = \"Diff\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;diff=$diff&amp;oldid=$oldid &\" }"
	fi
	echo "		Entry = \"Hist\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;action=history &\" }"
	echo "		Entry = \"$user&apos;s profile\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=User:${userurl:-$user} &\" }"
	echo "		Entry = \"$user&apos;s talk page\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=User_talk:${userurl:-$user} &\" }"
	echo "		Entry = \"$user&apos;s contributions\" { Actions = \"Exec ${3:-firefox} $1/index.php?title=Special:Contributions/${userurl:-$user} &\" }"
	echo '	}'
fi
done);
if [ "$menu" == "" ];then
	echo "Entry = \"There are no article changes to update\" {}"
else
	echo "$menu"
fi
	echo "}"
