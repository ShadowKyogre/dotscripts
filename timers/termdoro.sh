#!/bin/bash

INTERVAL="${1:-0}"
FONT="3x5"
LOG_HANDLER="${LOG_HANDLER:-termdoro_log}"

function termdoro_log() {
	if [[ -z "${LOG_FILE}" ]]; then
		LOG_FILE=$(mktemp -t "termdoro-intervals.XXXXXXXXX" -q)
	fi
	printf "${INTERVAL}\t${TIME1}\t${TIME2}\n" >> ${LOG_FILE}
}

while true; do
	TIME1="$(date "+%Y-%m-%d %H:%M:%S")"
	termdown -a "25m" -f "${FONT}" -T "Pomodoro ${INTERVAL}"
	EXIT_CODE="$?"
	TIME2="$(date "+%Y-%m-%d %H:%M:%S")"
	if [[ "${EXIT_CODE}" != 0 ]]; then
		exit
	fi
	${LOG_HANDLER} ${TIME1} ${TIME2}
	if [[ "${INTERVAL}" == "3" ]];then
		termdown -a "30m" -f "${FONT}" -T "Long Break"
	else
		termdown -a "5m" -f "${FONT}" -T "Short Break"
	fi
	EXIT_CODE="$?"
	if [[ "${EXIT_CODE}" != 0 ]]; then
		exit
	fi
	INTERVAL=$(( (${INTERVAL} + 1) % 4 ))
done
