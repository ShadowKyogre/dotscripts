#!/bin/sh

for client in $(tmux list-clients -F '#{client_tty}');do
	tmux display-message -c "${client}" "${1}"
done
