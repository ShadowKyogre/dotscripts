#!/bin/bash

#by ShadowKyogre (contact at shadowkyogre@aim.com or alternate email/IM if asked for)
#checks your dA messages for you
#TODO:add ability to use on multiple accounts?
#TODO:add ability to pick which one to notify and whether to display difference from last time to current
#TODO:add more options to output specific types
#TODO:output only diff
#TODO:MOAR DETAILED output per subtype
#TODO:grab icons?
#TODO:overlay # on each icon type?
#Please don't uncomment anything here yet!

#convert /home/shadowkyogre/.icons/Breathless/48x48/apps/3d.png -gravity southwest -stroke '#000C' -strokewidth 2 -annotate 0 '3' -stroke  none   -fill white -annotate 0 '3' outhere.png
#howto overlay numbers
USERNAME="$1"
PASSWORD="$2"
#checkInterval="hour" hour, month, day, or immediate
#makeIcons=0
#groupIcon="/path/to/file.png"
#watchlistIcon="/path/to/file.png"
#deviationIcon="/path/to/file.png"
#feedbackIcon="/path/to/file.png"
#notesIcon="/path/to/file.png"
#noticeIcon="/path/to/file.png"
#correspondenceIcon="/path/to/file.png"
#msgIcon="/path/to/file.png"
#numberFG='#YRCOLR'
#numberBG='#YRCOLR'
#grabFace="computer"

check(){
	if [[ -e ~/.config/dAcheckrc ]];then
		source ~/.config/dAcheckrc
	else
		touch ~/.config/dAcheckrc
		if [[ -z "$USERNAME" || -z "$PASSWORD" ]];then
			echo "Please put in your username and password for the first run"
			echo "You could also fill out ~/.config/dAcheckrc like this:"
			echo "USERNAME=\"yourusername\""
			echo "PASSWORD=\"yourpassword\""
			echo "clearCookies=0 #0 or 1"
			exit 1
		fi
		echo "USERNAME=\"$USERNAME\"" > ~/.config/dAcheckrc
		echo "PASSWORD=\"$PASSWORD\"" >> ~/.config/dAcheckrc
		echo "clearCookies=0 #0 or 1" >> ~/.config/dAcheckrc
		#echo "makeIcons=0 #0 or 1" >> ~/.config/dAcheckrc
		echo "checkInterval=\"hour\" #hour, day, month, or immediate" >> ~/.config/dAcheckrc
		clearCookies=0
		#makeIcons=0
		checkInterval="hour"
	fi
}

clear(){
	rm -f ~/.config/dAcheck.cjar
}

login(){
if (( $(ping google.com -c 3 > /dev/null;echo $?) != 0 ));then
	echo "Your network is down."
	exit 1
fi
if [[ -s ~/.config/dAcheck.cjar ]];then
	if [[ "$(echo $(cat ~/.config/dAcheck.cjar))" == "" ]];then 
	rm -f ~/.config/dAcheck.cjar
	curl -A "Mozilla/4.73 [[en] (X11; U; Linux 2.2.15 i686)" -s \
	--cookie ~/.config/dAcheck.cjar --cookie-jar ~/.config/dAcheck.cjar \
	--data-urlencode "username=$USERNAME" \
	--data-urlencode "password=$PASSWORD" \
	--data-urlencode "action=Login" \
	--data "reusetoken=1" \
	--location "https://www.deviantart.com/users/login" > /dev/null
	fi
else
	curl -A "Mozilla/4.73 [[en] (X11; U; Linux 2.2.15 i686)" -s \
	--cookie ~/.config/dAcheck.cjar --cookie-jar ~/.config/dAcheck.cjar \
	--data-urlencode "username=$USERNAME" \
	--data-urlencode "password=$PASSWORD" \
	--data-urlencode "action=Login" \
	--data "reusetoken=1" \
	--location "https://www.deviantart.com/users/login" > /dev/null
fi
TEMP_FILE="$(mktemp)"
curl -A "Mozilla/4.73 [[en] (X11; U; Linux 2.2.15 i686)" -s \
--cookie ~/.config/dAcheck.cjar --cookie-jar ~/.config/dAcheck.cjar \
--data "username=" \
--data "password=" \
--data "action=Login" \
--location "https://www.deviantart.com/users/login" -o "$TEMP_FILE"
}

retrieve(){
if [[ "$(grep "Unsplinter Menu" $TEMP_FILE -o)" == "Unsplinter Menu" ]];then    
	if [[ "$(grep "Group Message" $TEMP_FILE -o)" == "Group Messages" ]];then
		thisGroup=$(grep -E --regexp='groups"><i class="i16"></i>[[1234567890, ]+<' $TEMP_FILE -o | \
		sed 's|groups"><i class="i16"></i>||;s|<||;s|,||;s| ||g')
	fi
	thisdAwatch=$(grep -E --regexp='deviantwatch"><i class="icon i1"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
	sed 's|deviantwatch"><i class="icon i1"></i>||;s|<||;s|,||;s| ||g')
	thisDeviations=$(grep -E --regexp='deviations"><i class="icon i1"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
	sed 's|deviations"><i class="icon i1"></i>||;s|<||;s|,||;s| ||g')
	thisFeedback=$(grep -E --regexp='feedback"><i class="icon i2"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
	sed 's|feedback"><i class="icon i2"></i>||;s|<||;s|,||;s| ||g')
	if [[ "$(grep correspondence $TEMP_FILE -o)" == "correspondence" ]];then
		thisCorrespondence=$(grep -E --regexp='correspondence"><i class="icon i17"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
		sed 's|correspondence"><i class="icon i17"></i>||;s|<||;s|,||;s| ||g')
	fi
	thisNewNotes=$(grep -E --regexp='Notes"><i class="icon i9"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
		sed 's|Notes"><i class="icon i9"></i>||;s|<||;s|,||;s| ||g')
	if [[ "$(grep notices $TEMP_FILE -o)" == "notices" ]];then
		thisNotices=$(grep -E --regexp='notices"><i class="icon i3"></i>.[[1234567890,]+<' $TEMP_FILE -o | \
		sed 's|notices"><i class="icon i3"></i>||;s|<||;s|,||;s| ||g')
	fi
else
	thisMsg=$(grep '<a class=oh-l href="http://my.deviantart.com/messages/"><i class="icon h-icon i3"></i> &nbsp;' $TEMP_FILE | \
        sed 's|<a class=oh-l href="http://my.deviantart.com/messages/"><i class="icon h-icon i3"></i> &nbsp;||;s|,||' | \
        sed 's|>||;s| <img src="https://s.deviantart.com/minish/main/radbelow.png" class=oh-mg width=11 height=11></a></div>    <div class="oh-ml"||' | \
        sed 's| ||')
fi
}
	
calculate(){
if [[ -e ~/.config/dAcheck.msg ]];then
	source ~/.config/dAcheck.msg
else
	touch ~/.config/dAcheck.msg
fi
if [[ "$(grep "Unsplinter Menu" $TEMP_FILE -o)" == "Unsplinter Menu" ]];then 
	if [[ "$(grep "Group Message" $TEMP_FILE -o)" == "Group Messages" ]];then
		if (( $prevGroup < $thisGroup ));then
			diffGroup=$(($thisGroup - ${prevGroup:=$thisGroup}))
		else
			diffGroup=$((${prevGroup:=$thisGroup} - $thisGroup))
		fi
	fi
	if [[ $thisdAwatch -eq 0 ]];then
		diffdAwatch=0
	elif (( ${prevdAwatch:-0} < $thisdAwatch ));then
		diffdAwatch=$(($thisdAwatch - ${prevdAwatch:=$thisdAwatch}))
	else
		diffdAwatch=$((${prevdAwatch:=$thisdAwatch} - $thisdAwatch))
	fi
	
	if [[ $thisDeviations -eq 0 ]];then
		diffDeviations=0
	elif (( ${prevDeviations:-0} < $thisDeviations ));then
		diffDeviations=$(($thisDeviations - ${prevDeviations:=$thisDeviations}))
	else
		diffDeviations=$((${prevDeviations:=$thisDeviations} - $thisDeviations))
	fi
	
	if [[ $thisFeedback -eq 0 ]];then
		diffFeedback=0
	elif (( ${prevFeedback:-0} < $thisFeedback ));then
		diffFeedback=$(($thisFeedback - ${prevFeedback:=$thisFeedback}))
	else
		diffFeedback=$((${prevFeedback:=$thisFeedback} - $thisFeedback))
	fi
	
	if [[ "$(grep correspondence $TEMP_FILE -o)" == "correspondence" ]];then
		if (( ${prevCorrespondence:-0} < $thisCorrespondence ));then
			diffCorrespondence=$(($thisCorrespondence - ${prevCorrespondence:=$thisCorrespondence}))
		else
			diffCorrespondence=$((${prevCorrespondence:=$thisCorrespondence} - $thisCorrespondence))
		fi
	fi
	
	if [[ $thisNewNotes -eq 0 ]];then
		diffNewNotes=0
	elif (( ${prevNewNotes:-0} < $thisNewNotes ));then
		diffNewNotes=$(($thisNewNotes - ${prevNewNotes:=$thisNewNotes}))
	else
		diffNewNotes=$((${prevNewNotes:=$thisNewNotes} - $thisNewNotes))
	fi
	
	if [[ "$(grep notices $TEMP_FILE -o)" == "notices" ]];then
		if (( ${prevNotices:-0} < $thisNotices ));then
			diffNotices=$(($thisNotices - ${prevNotices:=$thisNotices}))
		else
			diffNotices=$((${prevNotices:=$thisNotices} - $thisNotices))
		fi
	fi
else	
	if [[ $this2Msg -eq 0 ]];then
		diffMsg=0
	elif (( ${prevMsg:-0} < $thisMsg ));then
		diffMsg=$(($thisMsg - ${prevMsg:=$thisMsg}))
	else
		diffMsg=$((${prevMsg:=$thisMsg} - $thisMsg))
	fi
fi
}

display(){
if [[ "$(grep "Unsplinter Menu" $TEMP_FILE -o)" == "Unsplinter Menu" ]];then 
	if [[ "$(grep "Group Message" $TEMP_FILE -o)" == "Group Messages" ]];then
		if (( $prevGroup < $thisGroup ));then
			echo "$thisGroup group message(s), $diffGroup new message(s)"
		else
			echo "$thisGroup group message(s), $diffGroup message(s) deleted"
		fi
	fi
	if [[ $thisdAwatch -eq 0 ]];then
		echo "No messages from your watchlist"
	elif (( ${prevdAwatch:-0} < $thisdAwatch )) || [[ $diffdAwatch -eq 0 ]];then
		echo "$thisdAwatch watchlist message(s), $diffdAwatch new message(s)"
	else
		echo "$thisdAwatch watchlist message(s), $diffdAwatch message(s) deleted"
	fi
	
	if [[ $thisDeviations -eq 0 ]];then
		echo "No watched deviations"
	elif (( ${prevDeviations:-0} < $thisDeviations )) || [[ $diffDeviations -eq 0 ]];then
		echo "$thisDeviations watched deviations(s), $diffDeviations new deviation(s)"
	else
		echo "$thisDeviations watched deviation(s), $diffDeviations deviation(s) deleted"
	fi
	
	if [[ $thisFeedback -eq 0 ]];then
		echo "No feedback"
	elif (( ${prevFeedback:-0} < $thisFeedback )) || [[ $diffFeedback -eq 0 ]];then
		echo "$thisFeedback feedback, $diffFeedback new feedback"
	else
		echo "$thisFeedback feedback, $diffFeedback feedback deleted"
	fi
	
	if [[ "$(grep correspondence $TEMP_FILE -o)" == "correspondence" ]];then
		if (( ${prevCorrespondence:-0} < $thisCorrespondence ));then
			echo "$thisCorrespondence correspondence(s), $diffCorrespondence new correspondence(s)"
		else
			echo "$thisCorrespondence watched correspondence(s), $diffCorrespondence correspondence(s) deleted"
		fi
	fi
	
	if [[ $thisNewNotes -eq 0 ]];then
		echo "No unread notes"
	elif (( ${prevNewNotes:-0} < $thisNewNotes )) || [[ $diffNotes -eq 0 ]];then
		echo "$thisNewNotes unread note(s), $diffNewNotes new unread note(s)"
	else
		echo "$thisNewNotes unread note(s), $diffNewNotes unread note(s) deleted"
	fi
	
	if [[ "$(grep notices $TEMP_FILE -o)" == "notices" ]];then
		if (( ${prevNotices:-0} < $thisNotices ));then
			echo "$thisNotices notice(s), $diffNotices new notices(s)"
		else
			echo "$thisNotices notices(s), $diffNotices notices(s) deleted"
		fi
	fi
else	
	if [[ $this2Msg -eq 0 ]];then
		echo "No messages"
	elif (( ${prevMsg:-0} < $thisMsg )) || [[ $diffMsg -eq 0 ]];then
		echo "$thisMsg message(s), $diffMsg new message(s)"
	else
		echo "$thisMsg message(s), $diffMsg new message(s) deleted"
	fi
fi
}

settings(){
echo -n "" > ~/.config/dAcheck.msg
if [[ "$(grep "Unsplinter Menu" $TEMP_FILE -o)" == "Unsplinter Menu" ]];then
	if [[ "$(grep "Group Message" $TEMP_FILE -o)" == "Group Messages" ]];then
		echo "prevGroup=$thisGroup" >> ~/.config/dAcheck.msg
	fi
	echo "prevdAwatch=$thisdAwatch" >> ~/.config/dAcheck.msg
	echo "prevDeviations=$thisDeviations" >> ~/.config/dAcheck.msg
	echo "prevFeedback=$thisFeedback" >> ~/.config/dAcheck.msg
	if [[ "$(grep correspondence $TEMP_FILE -o)" == "correspondence" ]];then
		echo "prevCorrespondence=$thisCorrespondence" >> ~/.config/dAcheck.msg
	fi
	echo "prevNewNotes=$thisNewNotes" >> ~/.config/dAcheck.msg
	if [[ "$(grep notices $TEMP_FILE -o)" == "notices" ]];then
		echo "prevNotices=$thisNotices" >> ~/.config/dAcheck.msg
	fi
else
	echo "prevMsg=$thisMsg" >> ~/.config/dAcheck.msg
fi
sed -i 's| ||g' ~/.config/dAcheck.msg
}

check
if [[ $clearCookies -eq 1 ]];then
	clear
fi
login
if [ -z $symbol ];then
	echo "symbol=\"$(grep -E 'symbol":"."' -m 1 -o $TEMP_FILE|sed 's|symbol":"\(.\)"|\1|')\" #THIS IS AUTOWRITTEN. PLEASE DO NOT EDIT THIS" >> ~/.config/dAcheckrc
fi
retrieve
calculate
#TODO: force update of prev variables once it detects a deletion
display
#only export prev immediately if the interval is set to immediate
case $checkInterval in
"hour")
	if (( $(date +%k)-${lastCheck:-0} > 0 ));then
		settings
		echo "lastCheck=$(date +%k)" >> ~/.config/dAcheck.msg
	fi
	;;
"month")
	if (( $(date +%m)-${lastCheck:-0} > 0 ));then
		settings
		echo "lastCheck=$(date +%m)" >> ~/.config/dAcheck.msg
	fi
	;;
"day")
	if (( (($(date +%d)-${lastCheck:-0})) > 0 ));then
		settings
		echo "lastCheck=$(date +%d)" >> ~/.config/dAcheck.msg
	fi
	;;
"immediate")
	settings
	;;
esac
rm -f $TEMP_FILE

#urpage=$(echo http:\/\/$(echo $|sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/).deviantart.com)
#<a href="http://shadowkyogre.deviantart.com/"><img title="shadowkyogre" alt=":iconshadowkyogre:" src="http://a.deviantart.net/avatars/s/h/shadowkyogre.gif?2" style="float: left; margin-right: 2px; margin-bottom: 2px;" class="avatar"></a>
#avatar=$(curl -A "Mozilla/4.73 [[en] (X11; U; Linux 2.2.15 i686)" -s $urpage|grep avatar|grep $(echo $USERNAME|y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/) -m 1|sed 's|<link href="||;s|\?." rel="apple-touch-icon"/>||')
#wget $avatar -o
#this is for possibly avatar synching on your pc and account
