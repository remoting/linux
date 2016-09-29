
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias pp='ps auxf | grep -v ]$'

PS1='\[\e[31m〇\[\e[m\] '