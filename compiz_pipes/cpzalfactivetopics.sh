#!/bin/bash

##############################################################
## #! Forums Active Topics Pipe Menu                        ##
##                                                          ##
## v 1.0 by jpope 01.18.2010                                ##
##   - based on conky config by mrpeachy @                  ##
##     http://crunchbanglinux.org/forums/post/51330/#p51330 ##
##                                                          ##
## v 1.1 by jpope 01.19.2010                                ##
##                                                          ##
##############################################################

## Settings ##################################################
browser=$(echo ${1:-firefox})
maxthreads=${2:-5}
##############################################################
DIR=$(echo /tmp/)
tmpfile=$(echo forumspipemenu.html)
forumlink=$(echo https://bbs.archlinux.org/search.php?action=show_24h)
curl $forumlink > $DIR$tmpfile
#tempfile=$(echo file://$DIR$tmpfile)
tempfile=$DIR$tmpfile
th=1
title=$(echo "echo <separator name=\"CRUNCHBANGLINUX.ORG FORUM ACTIVITY\"/>")
itemforums=$(echo "echo <item type=\"launcher\"><name>Goto Recent Topics --&lt;</name>")
itemforums_execute=$(echo "echo $browser $forumlink")
item_close=$(echo "echo </item>")
execute=$(echo "echo <command>")
execute_close=$(echo "echo </command>")
separator=$(echo "echo <separator/>")

        $title
            $itemforums
                    $execute
                        $itemforums_execute
                    $execute_close
            $item_close
        $separator
        while [ $th -le $maxthreads ]; do
            topic=$(less $tempfile | grep -n '</span> <a href' | sed -n $th\p | awk -F'/">' '{print $2}' | awk -F'</a>' '{print $1}' | sed "s|&#039;|'|g" | fold -sw 40)
            t_link=$(less $tempfile | grep -n '</span> <a href' | sed -n $th\p | awk -F'href="' '{print $2}' | awk -F'">' '{print $1}')
            timestamp=$(less $tempfile | grep -n '<td class="tcr' | sed -n $th\p | awk -F'>' '{print $3 $5}' | sed -e 's|</a| |' | sed -e 's|</span||' | sed -e 's/Today/Last post at/')
            ts_link=$(less $tempfile | grep -n '<td class="tcr' | sed -n $th\p | awk -F'href="' '{print $2}' | awk -F'">' '{print $1}')

            item_topic=$(echo "echo <item type="launcher"><name>$th $topic</name>")
            item_topic_link=$(echo "echo $browser \"https://bbs.archlinux.org/$t_link\"")
            item_timestamp=$(echo "echo <item type="launcher"><name>$timestamp</name>")
            item_timestamp_link=$(echo "echo $browser \"https://bbs.archlinux.org/$ts_link\"")

            $item_topic
                    $execute
                        $item_topic_link
                    $execute_close
            $item_close
            $item_timestamp
                    $execute
                        $item_timestamp_link
                    $execute_close
            $item_close
        $separator
        th=$(( $th + 1 ))
        done

echo $(rm $DIR$tmpfile)
