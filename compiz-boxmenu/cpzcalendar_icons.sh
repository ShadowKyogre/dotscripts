 #!/bin/sh
 #
 # date-menu.sh
 #
 # This is in the public domain.  Honestly, how can you claim anything to something
 # this simple?
 #
 # Outputs a simple openbox pipe menu to display the date, time, and calendar.
 # You need 'date' and 'cal'.  You should have these.  Additionally, the calendar
 # only appears properly formated if you use a mono spaced font.
 
 # Outputs the selected row from the calender output.
 # If you don't use a mono spaced font, you would have to play with spacing here.
 # It would probably involve a very complicated mess.  Is there a way to force a
 # different font per menu?
 function calRow() {
   cal | gawk -v row=$1 '{ if (NR==row) { print $0 } }'
 }
 
 # Build the menu
 cat << EOFMENU
   <separator name="`date +%A\ \ \ \ \ \ \ \ \ \ \ \ %I\:%M\ %p`" icon="date"/>
   <item type="launcher"><name>`date +%B\ %d,\ %Y`</name></item>
   <separator/>
   <item type="launcher"><name>`calRow 2`</name></item>
   <item type="launcher"><name>`calRow 3`</name></item>
   <item type="launcher"><name>`calRow 4`</name></item>
   <item type="launcher"><name>`calRow 5`</name></item>
   <item type="launcher"><name>`calRow 6`</name></item>
   <item type="launcher"><name>`calRow 7`</name></item>
   <item type="launcher"><name>`calRow 8`</name></item>
 EOFMENU
