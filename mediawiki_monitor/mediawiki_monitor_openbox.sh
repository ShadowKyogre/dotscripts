#!/bin/sh
#TODO: Fix for wikipedia
#regex idea so far:
#$mainurl=$(echo $1|grep 'http://[^/]*' -o)
page=$(curl -s "$1/index.php?title=Special:RecentChanges&limit=${2:-50}")
wiki=$(echo "$page"|grep -E '<title>.*</title>'|sed 's|Recent changes - ||;s|<title>||;s|</title>||;s|^[ \t]*||g')
recent=$(echo "$page"|awk 'BEGIN {x=0}
{
if ($0~"<ul class=\"special\">") {x=1}
if (x==1) {print $0}
if ($0~"<div class=\"printfooter\">") {x=0}
}'|sed 's/<ul class="special">//g;s|<div class="printfooter">||;s|</ul>||g;/^$/d')
echo "<openbox_pipe_menu>"
echo "<item label=\"Visit $wiki\"><action label=\"Execute\"><command>${3:-firefox} $1</command></action></item>"
echo "<item label=\"Check $wiki&apos;s uploads\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/upload</command></action></item>"
echo "<item label=\"Check $wiki&apos;s blocks\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/block</command></action></item>"
echo "<item label=\"Check $wiki&apos;s protections\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/protect</command></action></item>"
echo "<item label=\"Check $wiki&apos;s new users\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/newusers</command></action></item>"
echo "<item label=\"Check $wiki&apos;s patrols\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/patrol</command></action></item>"
echo "<item label=\"Check $wiki&apos;s deletions\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/delete</command></action></item>"
echo "<item label=\"Check $wiki&apos;s moves\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/move</command></action></item>"
echo "<item label=\"Check $wiki&apos;s user renames\"><action label=\"Execute\"><command>${3:-firefox} $1/Special:Log/renameuser</command></action></item>"
echo "<separator label=\"Article changes\" />"
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
	id=$(echo "$title $time"|sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ /abcdefghijklmnopqrstuvwxyz-/;s/://g')
	statsuser=$(echo "$line"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)</.*>.*<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a> <' -o)
	stats=$(echo "$statsuser"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)<' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	user=$(echo "$statsuser"|grep -E '<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a>' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	userurl=$(echo "$statsuser"|grep -E 'href=".*/(index.php\?title=)?User:.*(&amp;.*)?"( title| class)' -o|sed 's/href="//g;s/"//g;s/ title=.* class//g;s/ class=.* title//g'|grep -E '(index.php\?title=|/)?User:.*(&amp;action.*)?' -o|sed 's/User://g;s/index.php\?title=//g;s/\///g;s/&amp;action.*//g;s/ title=.* class//g;s/ class=.* title//g;s|^index.php?title=||')
	echo "	<menu label=\"$time @ $title by $user $stats\" id=\"$id\">"
	echo "		<item label=\"${comment:-"No comment on this change."}\" />"
	echo "		<item label=\"Visit $title\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=$link</command></action></item>"
	if [ "$diff" != "" ];then
		echo "		<item label=\"Diff\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;diff=$diff&amp;oldid=$oldid</command></action></item>"
	fi
	echo "		<item label=\"Hist\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;action=history</command></action></item>"
	echo "		<item label=\"$user&apos;s profile\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=User:${userurl:-$user}</command></action></item>"
	echo "		<item label=\"$user&apos;s talk page\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=User_talk:${userurl:-$user}</command></action></item>"
	echo "		<item label=\"$user&apos;s contributions\"><action label=\"Execute\"><command>${3:-firefox} $1/index.php?title=Special:Contributions/${userurl:-$user}</command></action></item>"
	echo '	</menu>'
fi
done);
if [ "$menu" == "" ];then
	echo "<item label=\"There are no article changes to update\" />"
else
	echo "$menu"
fi
	echo "</openbox_pipe_menu>"
