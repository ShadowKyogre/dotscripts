#!/bin/sh

tsession="${1:-dropdown}"
twindow="${2:-breakcycle}"

bc_id="$(tmux list-windows -F '#{window_id}:#W' -t "${tsession}"|grep ":${twindow}$"|cut -d: -f1)"

if [ -z "${bc_id}" ];then
	exit
fi

bc_pane="${bc_id}.0"
tmux send-keys -t "${bc_pane}" Space
