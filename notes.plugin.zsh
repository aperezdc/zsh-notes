#! /bin/zsh
#
# notes.plugin.zsh
# Copyright (C) 2018 Adrian Perez <aperez@igalia.com>
#
# Distributed under terms of the MIT license.
#

: ${ZSH_NOTES_HOME:=${HOME}/Notes}

function notes-edit
{
	emulate -L zsh

	[[ -d ${ZSH_NOTES_HOME} ]] || mkdir -p "${ZSH_NOTES_HOME}"

	local -a output
	read -A -d '\n' -r output < <( command find "${ZSH_NOTES_HOME}" \
		-type f -name '*.md' | sed -e 's/\.md$//' | fzf \
			--delimiter=/ --nth=-1 --with-nth=-1 \
			--query="${LBUFFER}" --print-query \
			--bind='ctrl-n:print-query' \
			--layout=reverse \
		)

	local file_path
	if [[ ${#output[@]} -eq 3 ]] ; then
		file_path="${output[2]}.md"
	elif [[ ${#output[@]} -eq 2 ]] ; then
		file_path="${output[1]}.md"
	else
		zle redisplay
		return
	fi

	if [[ ! -r ${file_path} ]] ; then
		file_path="${ZSH_NOTES_HOME}/${file_path}"
	fi

	"${EDITOR:-${VISUAL:-vi}}" "${file_path}"
}

zle -N notes-edit
