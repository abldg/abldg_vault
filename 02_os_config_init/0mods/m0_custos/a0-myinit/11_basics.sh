#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 11_basics.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
#-------------------------------------------
alias sfa='alias'
alias noc='command grep -Ev "^($|#)"'
alias npa='[ X != X$(command -v netplan) ] && netplan apply'
alias rld='source ~/.bashrc'
alias c='clear'
alias p='pwd'
alias q='exit'
alias tf='tail -f'
# alias chg2cn='export LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8'
# alias chg2en='export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8'
alias chg2root='su - root'
alias wget='command wget --no-log -q'
alias crr='complete -r'
alias srm='sudo rm -rf'
##ip route----------------------------------
alias ipr='ip -4 route show'
alias ipra='ip -4 route add'
alias iprd='ip -4 route del'
alias iprr='ip -4 route replace'
#-------------------------------------------
alias td='tree --dirsfirst'
alias td1='tree --dirsfirst -L 1'
#-------------------------------------------
alias sc='screen -S'
alias scl='screen -ls'
# alias scd='screen -d'
alias scr='screen -r'
alias scw='screen -wipe'
alias scd='screen -dmLS'
##systemctl---------------------------------
alias sctl_bgn='systemctl start'
alias sctl_rld='systemctl daemon-reload'
alias sctl_sts='systemctl status'
alias sctl_hlt='systemctl stop'
alias sctl_rst='systemctl restart'
#-------------------------------------------
alias lrp='netstat -nlpt'
alias lrp4='netstat -nlpt4'
alias lrpa='netstat -nlp'
alias lrpu='netstat -nlpu'
#-------------------------------------------
if [ X != X$(command -v dircolors) ]; then
  [ -r ~/.dircolors ] && dircolors -b ~/.dircolors &>/dev/null
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
#-------------------------------------------
eval 'alias l="ls -CF"'
eval 'alias la="ls -la"'
eval 'alias lh="ls -lh"'
eval 'alias ll="ls -l"'
eval 'alias lt="ls -lrt"'
eval 'alias sa="dha"'
eval 'alias .l="ls -l"'
eval 'alias l.="ls -d .*"'
eval 'alias lld.="ls -l -d .*"'
#-------------------------------------------
eval 'alias .b="cd -"'
eval 'alias .m="cd ~/.myinit"'
eval 'alias .o="cd ~/.osci"'
eval 'alias .v="cd ~/.vscode-server"'
eval 'alias .1="cd .."'
eval 'alias .2="cd ../.."'
eval 'alias .3="cd ../../.."'
eval 'alias ..="cd .."'
eval 'alias ...="cd ../.."'
