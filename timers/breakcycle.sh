#!/bin/sh

trap "exit" INT

if [ -n "$TMUX" ]
then
	tmux rename-window breakcycle
	tmux-pane-window-fmt.sh
fi
local first_loop=1 
while true
do
	if [ -n "$TMUX" ]; then
		tmux set-window-option -q '@bcycle-paused' 0
	fi
	if [ $first_loop -eq 1 -a \( -n "$1" \) ]; then
		oneshot-timer.sh 0 "$1" "Computer time" "Get off your seat"
		first_loop=0 
	else
		oneshot-timer.sh 0 "2h" "Computer time" "Get off your seat"
	fi
	if [ -n "$TMUX" ]; then
		tmux set-window-option -q '@bcycle-paused' 0
	fi
	oneshot-timer.sh 0 10m "Exercise time" "You can get back in seat"
done
