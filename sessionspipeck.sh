make_entry=1
username=""
tty=""
x11_display=""
session_n=0
seat=""
active=0

ck-list-sessions|while read line
do
	if [[ $line =~ Session[0-9]*: ]];then
		make_entry=0
		session_n=$(echo $line|grep -o "[0-9]*")
	fi
	if [[ $line =~ [\ \t]*seat\ \=\ \'Seat[0-9]+\' ]];then
		seat=$(echo ${line}|grep -o "[0-9]*")
	fi
	if [[ $line =~ [\ \t]*unix-user\ \=\ \'[0-9]+\' ]];then
		uid=$(echo $line|cut -d= -f2|grep -o '[0-9]*')
		username=$(getent passwd $uid|cut -d: -f1)
	fi
	if [[ $line =~ [\ \t]*(x11-)?display-device\ \=\ \'/dev/tty[0-9]+\' ]];then
		tty=$(echo $line|cut -d= -f2|grep -o '/dev/tty[0-9]*')
	fi
	if [[ $line =~ [\ \t]*(x11-)?display\ \=\ \':[0-9]+\' ]];then
		x11_display=$(echo $line|cut -d= -f2|grep -o ':[0-9]*')
	fi
	if [[ $session_n -gt 0 && ! -z ${username} && ! -z $tty && ${make_entry} -eq 0 ]];then
		if [[ $LIMIT_USER -eq 1 && ${username} != ${USER} ]];then
			continue
		fi
		echo '<item type="launcher">'
		if [[ ! -z ${x11_display} ]];then
			echo -e "\t<name>${username} (${x11_display})</name>"
		else
			echo -e "\t<name>${username} (${tty##/dev/})</name>"
		fi
		echo -e "\t<command>chvt ${tty##/dev/tty}</command>"
		#this is only for under X
		#echo -e "\t<command>xdotool key Ctrl+Alt+F${tty#/dev/tty}</command>"
		#seat_part="dbus-send --system --dest=org.freedesktop.ConsoleKit --type=method_call /org/freedesktop/ConsoleKit/Seat${seat}"
		#sess_part="org.freedesktop.ConsoleKit.Seat.ActivateSession objpath:/org/freedesktop/ConsoleKit/Session${session_n}"
		#echo -e "\t<command>${seat_part} ${sess_part}</command>"
		echo '</item>'
		make_entry=1
		x11_display=""
		username=""
		tty=""
		session_n=0
		seat=""
	fi
done
