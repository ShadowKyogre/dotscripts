#!/bin/sh

trap "exit" INT

declare -a TERMDOWN_ARGS
TERMDOWN_ARGS=(-c 5 -a -f 3x5)

breakcycle () {
	if [ -n "$TMUX" ]
	then
		tmux rename-window breakcycle
		pane_and_window_fmt.sh
	fi
	local first_loop=1 
	while true
	do
		if [ -n "$TMUX" ]
		then
			tmux set-window-option -q '@bcycle-paused' 0
		fi
		if [ $first_loop -eq 1 -a \( -n "$1" \) ]
		then
			oneshot 0 "$1" "Computer time" "Get off your seat"
			first_loop=0 
		else
			oneshot 0 "2h" "Computer time" "Get off your seat"
		fi
		if [ -n "$TMUX" ]
		then
			tmux set-window-option -q '@bcycle-paused' 0
		fi
		oneshot 0 10m "Exercise time" "You can get back in seat"
	done
}

oneshot () {
	if [ "$1" -ne 0 ]
	then
		pane_and_window_fmt.sh
	fi
	local time="$2" 
	local termtitle="$3" 
	local notititle="${4:-${3}}" 
	if [ -n "$termtitle" ]
	then
		termdown "$time" "${TERMDOWN_ARGS[@]}" -T "$termtitle"
		notify-send "$notititle"
		tmux-notify-all.sh "$notititle"
	else
		termdown "$time" "${TERMDOWN_ARGS[@]}"
	fi
}

script_name="$(basename "$0")"
script_name="${script_name%%.*}"

if [ "$script_name" = "oneshot" ];then
	oneshot "$@"
elif [ "$script_name" = "breakcycle" ];then
	breakcycle "$@"
fi
