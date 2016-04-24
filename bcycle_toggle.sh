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

notify_all_clients()
{
	for client in $(tmux list-clients -F '#{client_tty}');do
		tmux display-message -c "${client}" "${1}"
	done
}

if [  "$(tmux show-window-options -vt "${bc_id}" "${toggle_opt}")" -eq 0 ];then
	tmux set-window-option -t "${bc_id}" "${toggle_opt}" 1
	notify-send "Paused timer"
	notify_all_clients "Paused timer"
else
	tmux set-window-option -t "${bc_id}" "${toggle_opt}" 0
	notify-send "Unpaused timer"
	notify_all_clients "Paused timer"
fi
