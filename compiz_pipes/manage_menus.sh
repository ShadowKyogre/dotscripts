#!/bin/bash

IFS="
"
if [ "$1" == "-i" ];then
	for i in $XDG_CONFIG_HOME/compiz/boxmenu/*.xml
	do
	if [ "$i" == "$XDG_CONFIG_HOME/compiz/boxmenu/menu.xml" ];then
		echo "<item type=\"launcher\"><name>Edit default menu</name><command>compiz-boxmenu-editor</command><icon>${3:-gtk-edit}</icon></item>"
	else
		echo "<item type=\"launcher\"><name>Edit ${i#$XDG_CONFIG_HOME/compiz/boxmenu/}</name><command>compiz-boxmenu-editor $i</command><icon>${2:-gtk-edit}</icon></item>"
	fi
	done
else
	echo "<menu name=\"Menu files\">"
	for i in $XDG_CONFIG_HOME/compiz/boxmenu/*.xml
	do
	if [ "$i" == "$XDG_CONFIG_HOME/compiz/boxmenu/menu.xml" ];then
		echo "<item type=\"launcher\"><name>Edit default menu</name><command>compiz-boxmenu-editor</command></item>"
	else
		echo "<item type=\"launcher\"><name>Edit ${i#$XDG_CONFIG_HOME/compiz/boxmenu/}</name><command>compiz-boxmenu-editor $i</command></item>"
	fi
	done
fi
