#!/bin/bash

disp=${DISPLAY/.[0-9]/}
x_ids=$(pidof xinit)
x_lines=$(ps p ${x_ids}|grep " ${disp}")
only_this=$(echo "${x_lines}"|grep -o "^[ ]*[0-9]*")
#echo ${only_this/ \t/}
kill -TERM ${only_this} &
sleep 5 && kill -KILL ${only_this} && sync

#sh -c 'killall -TERM -u $(whoami) &amp; sleep 5 &amp;&amp; killall -KILL -u $(whoami) &amp;&amp; sync'
