#!/bin/sh

declare -a TERMDOWN_ARGS
TERMDOWN_ARGS=(-c 5 -a -f 3x5)

if [ "${1:-0}" -ne 0 -a -n "$TMUX" ]; then
	tmux-pane-window-fmt.sh
fi

timer_time="$2" 
termtitle="$3" 
notititle="${4:-${3}}" 

if [ -n "$termtitle" ]; then
	termdown "$timer_time" "${TERMDOWN_ARGS[@]}" -T "$termtitle"
	notify-send "$notititle"
	tmux-notify-all.sh "$notititle"
else
	termdown "$timer_time" "${TERMDOWN_ARGS[@]}"
fi
