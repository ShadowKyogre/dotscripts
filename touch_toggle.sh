#!/bin/bash
touch_ids=$(xsetwacom --list devices|grep "type: TOUCH"|grep -Eo "id: [0-9]+"|sed 's/id: //g;s/\\n/ /g')
touch_ids=(${touch_ids//:/ })
tLen=${#touch_ids[@]}
for ((i=0; i<${tLen}; i++ ));
do
	if [ "$(xsetwacom --get ${touch_ids[$i]} touch)" == "on" ];then
		xsetwacom set ${touch_ids[$i]} touch off
	else
		xsetwacom set ${touch_ids[$i]} touch on
	fi
done
