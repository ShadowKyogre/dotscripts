#!/bin/bash
touch_ids=$(xsetwacom --list devices|grep "type: STYLUS"|grep -Eo "id: [0-9]+"|sed 's/id: //g;s/\\n/ /g')
touch_ids=(${touch_ids//:/ })
tLen=${#touch_ids[@]}

for device_id in ${touch_ids[@]}
do
	if [ "$(xsetwacom --get ${device_id} rotate)" == "half" ];then
		xsetwacom set ${device_id} rotate none
	else
		xsetwacom set ${device_id} rotate half
	fi
done
