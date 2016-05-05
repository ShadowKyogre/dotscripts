#!/bin/sh

name_to_code()
{
	retval=-1

	if expr "${1}" : black > /dev/null;then
		retval=0
	elif expr "${1}" : red > /dev/null;then
		retval=1
	elif expr "${1}" : green > /dev/null;then
		retval=2
	elif expr "${1}" : yellow > /dev/null;then
		retval=3
	elif expr "${1}" : blue > /dev/null;then
		retval=4
	elif expr "${1}" : magenta > /dev/null;then
		retval=5
	elif expr "${1}" : cyan > /dev/null;then
		retval=6
	elif expr "${1}" : white > /dev/null;then
		retval=7
	elif expr "${1}" : brightblack > /dev/null;then
		retval=8
	elif expr "${1}" : brightred > /dev/null;then
		retval=9
	elif expr "${1}" : brightgreen > /dev/null;then
		retval=10
	elif expr "${1}" : brightyellow > /dev/null;then
		retval=11
	elif expr "${1}" : brightblue > /dev/null;then
		retval=12
	elif expr "${1}" : brightmagenta > /dev/null;then
		retval=13
	elif expr "${1}" : brightcyan > /dev/null;then
		retval=14
	elif expr "${1}" : brightwhite > /dev/null;then
		retval=15
	fi

	echo "$retval"
}

print_code_renders() {
	local code="$1"
	echo -ne "${code}"
	echo -ne "\t\e[38;5;${code};1m#####\e[0m"
	echo -ne "\t\e[48;5;${code}m     \e[0m"
	echo -ne "\t\e[38;5;${code}m#####\e[0m"
	if [ \( "$code" -lt 8 \) ];then
		local code_30="$(expr "$code" + 30)"
		echo -ne "\t\e[${code_30};1m#####\e[0m"
		echo -ne "\t\e[${code_30}m#####\e[0m"
	fi
	echo
}

echo -e 'Color\t38;1\t48\t38\t30+n;1\t30+n'

if [ "$#" -gt 0  ];then
	for code in "$@";do
		if expr "${code}" : '[a-z]\+' > /dev/null;then
			code="$(name_to_code "${code}")"
		fi

		if [ \( "$code" -gt 255 \) -o  \(  "$code" -lt 0 \) ];then
			continue
		else
			print_code_renders "$code"
		fi
	done
else
	for code in {0..255};do
		print_code_renders "$code"
	done
fi
