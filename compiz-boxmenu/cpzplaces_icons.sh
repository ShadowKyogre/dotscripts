#!/bin/bash

filemanager="$1"

for bookmark in `sed 's/[ ][^ ]*$//;s|file:///|/|' ~/.gtk-bookmarks
` ; do
  echo '<item type="launcher">'
  echo '<name>'`basename ${bookmark}`'</name>'
  echo "<command>$filemanager ${bookmark}</command>"
  echo '<icon>user-bookmarks</icon>'
  echo '</item>'
done
