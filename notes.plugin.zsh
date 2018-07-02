#! /bin/zsh
#
# notes.plugin.zsh
# Copyright (C) 2018 Adrian Perez <aperez@igalia.com>
#
# Distributed under terms of the MIT license.
#

function notes-home
{
	emulate -L zsh
	local p
	zstyle -s :notes home p || p="${HOME}/Notes"
	builtin print -rl "${p:a}"
}

function notes-list-files
{
	emulate -L zsh
	setopt local_options nullglob
	print -nrl "$(notes-home)"/**/*.md(.on) ''
}

function notes-list
{
	emulate -L zsh
	setopt local_options nullglob
	print -nrl "$(notes-home)"/**/*.md(.on:t:r) ''
}

function --notes-list-fzf
{
	emulate -L zsh
	setopt local_options nullglob
	print -nrN "$(notes-home)"/**/*.md(om:t:r) ''
}

function --notes-fzf
{
	emulate -L zsh
	command fzf --read0 --ansi \
		--preview="cat '$(notes-home)'/{}.md" \
		--layout=reverse --inline-info \
		--preview-window=down:hidden \
		--bind=tab:toggle-preview \
		--bind=ctrl-n:print-query \
		--query="${1:-}"
}

function notes-pick-fzf
{
	emulate -L zsh

	local H=$(notes-home)
	local chosen=$(--notes-list-fzf | --notes-fzf "$@")

	if [[ -z ${chosen} ]] ; then
		return 1
	fi

	print -rl "$H/${chosen}.md"
}

function notes-edit-widget
{
	emulate -L zsh
	setopt local_options err_return

	local -a editor=( "${(f)$(whence -p "${EDITOR}" "${VISUAL}" vim nvim vi)}" )
	if [[ ${#editor} -eq 0 ]] ; then
		print '\bCannot find a suitable text editor' 1>&2
		zle redisplay
		return
	fi

	while true ; do
		local chosen=$(notes-pick-fzf)
		[[ -n ${chosen} ]] || break

		if [[ ! -r ${chosen} && ! -d $H ]] ; then
			command mkdir -p "$H"
		fi
		command "${editor[1]}" "${chosen}" < /dev/tty

		zstyle -t :notes:widget once || break
	done
	zle redisplay
}

zle -N notes-edit-widget
