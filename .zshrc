# Created by newuser for 5.1.1

export TERM=xterm-256color
export CLICOLOR=1
#export LSCOLORS=exfxcxdxbxegedabagacad
export LSCOLORS=gxfxaxdxcxegedabagacad

autoload compinit
compinit

autoload promptinit
promptinit

autoload colors
colors

zstyle ':completion:*' menu select
setopt completealiases

PROMPT="%{$fg_bold[red]%}〇%b%{$reset_color%} "
