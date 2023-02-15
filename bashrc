# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Vi keybindings
set -o vi

# No ESC timeout delay for vi keybindings
KEYTIMEOUT=1

# Custom prompt
PS1="\n\[\e[1;34m\]\w"
# Git branch
PS1+="\[\e[0m\]\$(git status &> /dev/null && echo ' on') \[\e[32m\]\$(git branch --show-current 2> /dev/null)\n"
PS1+='\[\e[0m\]$ '

# Load custom aliases
[[ ! ( -L ~/.alias || -f ~/.alias ) ]] || . ~/.alias

# Hook for non-versioned .bashrc.local
[[ ! -f ~/.bashrc.local ]] || . ~/.bashrc.local
