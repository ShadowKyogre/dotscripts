username=""
device=""
ttyn=0

bgn_compiz_boxmenu(){
	return
}
end_compiz_boxmenu(){
	return
}
fmt_compiz_boxmenu(){
	echo '<item type="launcher">'
	echo -e "\t<name>${1} (${2})</name>"
	echo -e "\t<command>chvt ${3}</command>"
	echo '</item>'
}


bgn_openbox(){
	echo "<openbox_pipe_menu>"
}
fmt_openbox(){
	echo -e "\t<item label=\"${1} (${2})\">"
	echo -e "\t\t<action name=\"Execute\">"
	echo -e "\t\t\t<command>chvt ${3}</command>"
	echo -e "\t\t</action>"
	echo -e "\t</item>"
}
end_openbox(){
	echo "</openbox_pipe_menu>"
}

bgn_pekwm(){
	echo "Dynamic {"
}
fmt_pekwm(){
	echo -e "\tEntry = \"${1} (${2})\" { Actions =\"Exec chvt ${3} &\" }"
}
end_pekwm(){
	echo "}"
}

bgn_"${1:-compiz_boxmenu}"

who|while read line
do
	username=$(echo "$line"|grep -o "^[a-z][-a-z0-9]*")
	device=$(echo "$line"|grep -oE "^[a-z][-a-z0-9]*[ ]*(tty|:)[0-9]*"|sed 's/^[a-z][-a-z0-9]*[ ]*//g')
	if [[ ${device} =~ : ]];then
		x_pids=$(pidof X)
		ttyn=$(ps hp "$x_pids"|grep -o "^[ ]*[0-9]*[ ]*tty[0-9]*"|sed 's/^[ ]*[0-9]*[ ]*tty//g')
	else
		ttyn="${device##tty}"
	fi
	if [[ ! -z "$username" && ! -z "$device" && ! -z "$ttyn" ]];then
		fmt_"${1:-compiz_boxmenu}" "${username}" "${device}" "${ttyn}"
	fi
	username=""
	device=""
	ttyn=0
done

end_"${1:-compiz_boxmenu}"
