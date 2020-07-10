#!/bin/bash

if [[ -z "${1}" ]];then
	TARGET_MONITOR="next"
elif [[ "${1}" == "main" ]];then
	TARGET_MONITOR="HDMI-A-1"
elif [[ "${1}" == "all" ]];then
	TARGET_MONITOR="desktop"
else
	TARGET_MONITOR="${1}"
fi


xsetwacom set "Wacom Bamboo 2FG 4x5 Pen stylus" MapToOutput "${TARGET_MONITOR}"
xsetwacom set "Wacom Bamboo 2FG 4x5 Finger touch" MapToOutput "${TARGET_MONITOR}"
xsetwacom set "Wacom Bamboo 2FG 4x5 Pad pad" MapToOutput "${TARGET_MONITOR}"
xsetwacom set "Wacom Bamboo 2FG 4x5 Pen eraser" MapToOutput "${TARGET_MONITOR}"
