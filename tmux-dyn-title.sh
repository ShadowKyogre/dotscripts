#!/bin/sh

DYN_FORMAT="${1:-#I:#W - #T#{?window_flags,#{window_flags\}, }}"
STATIC_FORMAT="${2:-#I:#W#{?window_flags,#{window_flags\}, }}"

current_format="$(tmux display-message -p '#{window-status-format}')" 

if [ "${current_format}" = "${STATIC_FORMAT}" ];then
	tmux setw window-status-current-format "${DYN_FORMAT}"
	tmux setw window-status-format "${DYN_FORMAT}"
elif [ "${current_format}" = "${DYN_FORMAT}" ];then
	tmux setw window-status-current-format "${STATIC_FORMAT}"
	tmux setw window-status-format "${STATIC_FORMAT}"
fi
