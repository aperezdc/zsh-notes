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
	local p=${ZSH_NOTES_HOME:=${HOME}/Notes}
	builtin print -r "${p:a}"
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
		--preview="cat '$(notes-home)/{}.md'" \
		--layout=reverse --inline-info \
		--preview-window=down:hidden \
		--bind=tab:toggle-preview \
		--bind=ctrl-n:print-query \
		--query="${1:-}"
}

function notes-pick-fzf
{
	emulate -L zsh
	local chosen="$(notes-home)/$(--notes-list-fzf | --notes-fzf).md"
	if [[ -r ${chosen} ]] ; then
		builtin print -r "${chosen}"
	fi
}

function notes-edit-widget
{
	emulate -L zsh
	setopt local_options err_return

	local H=$(notes-home)
	local chosen=$(--notes-list-fzf | --notes-fzf "${LBUFFER}")

	if [[ -z ${chosen} ]] ; then
		zle redisplay
		return
	fi

	chosen="$H/${chosen}.md"
	if [[ ! -r ${chosen} && ! -d $H ]] ; then
		command mkdir -p "$H"
	fi

	"${EDITOR:-${VISUAL:-vi}}" "${chosen}"
}

zle -N notes-edit-widget
