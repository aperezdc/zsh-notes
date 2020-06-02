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

function --notes-list-nullsep
{
	emulate -L zsh
	setopt local_options nullglob
	print -nrN "$(notes-home)"/**/*.md(om:t:r) ''
}

function --notes-list-lines
{
	emulate -L zsh
	setopt local_options nullglob
	print -nrl "$(notes-home)"/**/*.md(.on:t:r) ''
}

function notes-list
{
	--notes-list-lines "$@"
}

function --notes-pick-fzf-or-skim
{
	emulate -L zsh
	local bin=$1
	shift

	local -a cmd=(
		--read0
		--ansi
		--bind=ctrl-n:print-query
		--prompt='(notes) '
		"$@"
	)

	# Add preview command, if configured.
	local -a previewcmd
	if zstyle -t :notes:widget:preview enabled ; then
		if ! zstyle -a :notes:widget:preview command previewcmd ; then
			previewcmd=(cat)
		fi
		cmd+=(
			--preview="${previewcmd[*]} '$(notes-home)'/{}.md"
			--bind=tab:toggle-preview
			--preview-window=right
		)
	fi
	command "${bin}" "${cmd[@]}"
}

function --notes-pick-fzf
{
	emulate -L zsh
	--notes-pick-fzf-or-skim fzf --layout=reverse --inline-info --query="${1:-}"
}

function --notes-pick-skim
{
	emulate -L zsh
	--notes-pick-fzf-or-skim sk --reverse --query="${1:-}"
}

function --notes-pick-fzy
{
	emulate -L zsh
	command fzy --prompt='(notes) ' --query="${1:-}"
}

function notes-pick
{
	emulate -L zsh

	local pick
	local list='nullsep'
	if zstyle -s :notes:widget picker pick ; then
		case "${pick}" in
			fzf | skim)
				;;
			fzy)
				list='lines'
				;;
			*)
				print -lu 2 "Unsupported picker: ${pick}"
				return 1
				;;
		esac
	else
		pick='fzf'
	fi

	local H=$(notes-home)
	local chosen=$("--notes-list-${list}" | "--notes-pick-${pick}" "$@")

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

	local H=$(notes-home)
	while true ; do
		local chosen=$(notes-pick)
		if [[ -z ${chosen} ]] ; then
			break
		fi

		if [[ ! -r ${chosen} && ! -d $H ]] ; then
			command mkdir -p "$H"
		fi
		command "${editor[1]}" "${chosen}" < /dev/tty

		if zstyle -t :notes:widget once ; then
			break
		fi
	done
	zle redisplay
}

zle -N notes-edit-widget
