#!/bin/bash

wid=$(xdotool getwindowfocus)
win_x=$(xwininfo -id "${wid}"|grep "Absolute upper-left X"| cut -d: -f2)
win_y=$(xwininfo -id "${wid}"|grep "Absolute upper-left Y"| cut -d: -f2)
mon_height=$(xrandr|grep "*"|head -n1|cut -d' ' -f4|cut -d'x' -f2)

function at_monitor() {
	(( flat_y = ${win_y} "%" "${mon_height}" ))
	(( new_y = ${flat_y} + ${1:-0} * ${mon_height} ))
	echo "${new_y}"
}

function prev_monitor() {
	(( new_y = ${win_y} - ${1:-1} * ${mon_height} ))
	echo "${new_y}"
}

function next_monitor() {
	(( new_y = ${win_y} + ${1:-1} * ${mon_height} ))
	echo "${new_y}"
}

if [ -z "${1}" ]; then
	if [ "${win_y}" -gt "${mon_height}" ]; then
		new_y="$(prev_monitor)"
		xdotool windowmove "${wid}" "${win_x}" "${new_y}"
	else
		new_y="$(next_monitor)"
		xdotool windowmove "${wid}" "${win_x}" "${new_y}"
	fi
elif [ "${1}" -eq 1 ]; then
	if [ "${win_y}" -gt "${mon_height}" ]; then
		new_y="$(at_monitor 0)"
		xdotool windowmove "${wid}" "${win_x}" "${new_y}"
	fi
elif [ "${1}" -eq 2 ]; then
	if [ "${win_y}" -lt "${mon_height}" ]; then
		new_y="$(at_monitor 1)"
		xdotool windowmove "${wid}" "${win_x}" "${new_y}"
	fi
fi
