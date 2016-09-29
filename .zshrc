#export TERM=xterm-256color
#export CLICOLOR=1
#export LSCOLORS=exfxcxdxbxegedabagacad
#export LSCOLORS=gxfxaxdxcxegedabagacad

#
autoload compinit
compinit

#
autoload promptinit
promptinit

#
autoload colors
colors

#
zstyle ':completion:*' menu select
setopt completealiases


#
PROMPT="%{$fg_bold[red]%}〇%{$reset_color%} "

alias pp='ps auxf | grep -v ]$'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
