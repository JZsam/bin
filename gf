#! /usr/bin/env bash
set -euo pipefail
if [[ -z $(tmux ls) ]]; then
	tmux new-session -d
fi
declare -a path=(
"$HOME/git/*"
"$HOME/.config/*"
"$HOME/.local/bin"
"$HOME/.newsboat/"
"$HOME/.hammerspoon/"
"$HOME/org/"
"$HOME/org/*"
)
tmuxLS=$(tmux ls | awk -F : '{print $1}' | xargs)
dir=$(exa -d ${path[@]} | grep -v Icon | fzf --preview 'exa --tree -lu :500 {}')
name=$(printf %s $dir|awk -F "/" '{print $NF}')
exists=false
zero=false
for value in $tmuxLS
do
	if [[ $value = $name ]]; then
		exists=true
	elif [[ $value = "0" ]]; then
		zero=true
	fi
done
if [[ -z ${TMUX+x} ]]; then
	if [[ $exists = true ]]; then
		tmux attach-session -t $name
	else
		tmux new-session -c$dir -ds $name
		if [[ $zero = true ]]; then
			tmux kill-session -t 0
		fi
		tmux new-window nvim -c "cd $dir" $dir
		tmux -2 attach-session -d
	fi
else
	if [[ $exists = true ]]; then
		tmux switch-client -t $name
	else
		tmux new-session -c$dir -ds $name
		tmux new-window -t $name  nvim $dir
		tmux switch-client -t $name
	fi
fi
