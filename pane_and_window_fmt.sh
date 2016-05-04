if [ -n "$TMUX" ]
then
	tmux setw window-status-current-format "#I:#W - #T#{?window_flags,#{window_flags}, }"
	tmux setw window-status-format "#I:#W - #T#{?window_flags,#{window_flags}, }"
fi
