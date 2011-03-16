#!/bin/sh
#TODO: Fix for wikipedia
#regex idea so far:
#$mainurl=$(echo $1|grep 'http://[^/]*' -o)
#TODO: port to openbox
#TODO: use favicon as icon
#path to icon: $1/favicon.ico
page=$(curl -s "$1/index.php?title=Special:RecentChanges&limit=${2:-50}")
wiki=$(echo "$page"|grep -E '<title>.*</title>'|sed 's|Recent changes - ||;s|<title>||;s|</title>||;s|^[ \t]*||g')
recent=$(echo "$page"|awk 'BEGIN {x=0}
{
if ($0~"<ul class=\"special\">") {x=1}
if (x==1) {print $0}
if ($0~"<div class=\"printfooter\">") {x=0}
}'|sed 's/<ul class="special">//g;s|<div class="printfooter">||;s|</ul>||g;/^$/d')
echo "<item type=\"launcher\"><name>Visit $wiki</name><command>${3:-firefox} $1</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s uploads</name><command>${3:-firefox} $1/Special:Log/upload</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s blocks</name><command>${3:-firefox} $1/Special:Log/block</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s protections</name><command>${3:-firefox} $1/Special:Log/protect</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s new users</name><command>${3:-firefox} $1/Special:Log/newusers</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s patrols</name><command>${3:-firefox} $1/Special:Log/patrol</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s deletions</name><command>${3:-firefox} $1/Special:Log/delete</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s moves</name><command>${3:-firefox} $1/Special:Log/move</command></item>"
echo "<item type=\"launcher\"><name>Check $wiki&apos;s user renames</name><command>${3:-firefox} $1/Special:Log/renameuser</command></item>"
echo "<separator name=\"Article changes\"/>"
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
	comment=$(echo "$line"|grep -E '<span class="comment">\(.*\)</span>' -o|sed 's/<\/span>//g;s/<span class="comment">//g;s/<span class="autocomment">//g;s/<a href=".*" title=".*">→<\/a>/→ /g;s|\&|\&amp\;|g;s/&#32\;//g;s|<|\&lt\;|g;s|>|\&gt\;|g')
	statsuser=$(echo "$line"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)</.*>.*<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a> <' -o)
	stats=$(echo "$statsuser"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)<' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	user=$(echo "$statsuser"|grep -E '<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a>' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
	userurl=$(echo "$statsuser"|grep -E 'href=".*/(index.php\?title=)?User:.*(&amp;.*)?"( title| class)' -o|sed 's/href="//g;s/"//g;s/ title=.* class//g;s/ class=.* title//g'|grep -E '(index.php\?title=|/)?User:.*(&amp;action.*)?' -o|sed 's/User://g;s/index.php\?title=//g;s/\///g;s/&amp;action.*//g;s/ title=.* class//g;s/ class=.* title//g;s|^index.php?title=||')
	echo "	<menu name=\"$time @ $title by $user $stats\">"
	echo "		<item type=\"launcher\"><name>${comment:-"No comment on this change."}</name></item>"
	echo "		<item type=\"launcher\"><name>Visit $title</name><command>${3:-firefox} $1/index.php?title=$link</command></item>"
	if [ "$diff" != "" ];then
		echo "		<item type=\"launcher\"><name>Diff</name><command>${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;diff=$diff&amp;oldid=$oldid</command></item>"
	fi
	echo "		<item type=\"launcher\"><name>Hist</name><command>${3:-firefox} $1/index.php?title=page&amp;curid=$curid&amp;action=history</command></item>"
	echo "		<item type=\"launcher\"><name>$user&apos;s profile</name><command>${3:-firefox} $1/index.php?title=User:${userurl:-$user}</command></item>"
	echo "		<item type=\"launcher\"><name>$user&apos;s talk page</name><command>${3:-firefox} $1/index.php?title=User_talk:${userurl:-$user}</command></item>"
	echo "		<item type=\"launcher\"><name>$user&apos;s contributions</name><command>${3:-firefox} $1/index.php?title=Special:Contributions/${userurl:-$user}</command></item>"
	echo '	</menu>'
fi
done);
if [ "$menu" == "" ];then
	echo "<item type=\"launcher\"><name>There are no article changes to update</name></item>"
else
	echo "$menu"
fi
#sed 's|&|&amp;|g;s|'\''|&apos;|g;s|<|&lt;|g;s|>|&gt;|g;s|\"|&quot;|g' ?
#talk: $1/User_talk:<user>
#contrib: $1/Special:Contributions/<user>
#profile: $1/User:<user>
#
#page:
#$1/index.php?title=page&amp;curid=$curid&amp;action=history
#$1/index.php?title=page&amp;curid=$curid&amp;diff=$diff&amp;oldid=$oldid
#$1/index.php?title=User:$userurl
#$1/index.php?title=User_talk:$userurl
#$1/index.php?title=Special:Contributions/$userurl

#comment=$(echo "$line"|grep -E '<span class="comment">\(.*\)</span>' -o|sed 's/<\/span>//g;s/<span class="comment">//g;s/<span class="autocomment">//g;s/<a href=".*" title=".*">→<\/a>/→ /g;s/&#32\;//g;s|<|\&lt\;|g;s|>|\&gt\;|g'|head -c 30)
#statsuser=$(echo "$line"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)</.*>.*<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a> <' -o)
#stats=$(echo "$statsuser"|grep -E '(pos|neg|null)'\''>\((\+|-)?[,0-9]+\)<' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
#user=$(echo "$statsuser"|grep -E '<a href=".*"( title=".*" class=".*"| class=".*" title=".*")>.*</a>' -o|grep -E '>.*<' -o|sed 's/>//g;s/<//g')
