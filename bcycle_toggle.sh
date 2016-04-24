#!/bin/sh

tsession="${1:-dropdown}"
twindow="${2:-breakcycle}"
toggle_opt="${3:-@bcycle-paused}"

bc_id="$(tmux list-windows -F '#{window_id}:#W' -t "${tsession}"|grep ":${twindow}$"|cut -d: -f1)"

if [ -z "${bc_id}" ];then
	exit
fi

bc_pane="${bc_id}.0"
tmux send-keys -t "${bc_pane}" Space

if [  "$(tmux show-window-options -vt "${bc_id}" "${toggle_opt}")" -eq 0 ];then
	notify-send "Paused timer"
	tmux set-window-option -t "${bc_id}" "${toggle_opt}" 1
else
	notify-send "Unpaused timer"
	tmux set-window-option -t "${bc_id}" "${toggle_opt}" 0
fi
