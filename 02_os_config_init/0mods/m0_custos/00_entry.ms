#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 01_entry.sf
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 16:23:19
## VERS: 1.0.1
##==================================----------==================================
# mt::load_funcs() {
#   local thzmod_fullpath=${BASH_SOURCE%/*} newfile=
#   for newfile in ${thzmod_fullpath}/scripts/*_*.sh; do . $newfile; done
# }
# # : "#{{{{ BGN-ENTRY: $BASH_SOURCE"
# mt::load_funcs
# unset -f mt::load_funcs
# # : "#}}}} END-ENTRY: $BASH_SOURCE"

##////////////////////////////////////////////////////////////////////////////##
shfn::custos::extsinst::codesvr() {
  local thzmod_fullpath=${BASH_SOURCE%/*}
  local vscdt_fullpath="$HOME/.vscode-server/data"
  set -- $vscdt_fullpath/Machine $vscdt_fullpath/User && mkdir -p $@ 2>/dev/null
  mt::tip_step
  install -m 644 $thzmod_fullpath/*oth*/vf*-user-settings.json $2/settings.json
  install -m 644 $thzmod_fullpath/*oth*/vf*-machine-settings.json $1/settings.json
  install -m 644 $thzmod_fullpath/*oth*/vf*-machine-keybindings.json $1/keybindings.json
  ###
  local xf= && hash -r && case $(command -v code) in
  *remote-cli*) xf=code ;;
  "") [ X != X$(command -v webide) ] && xf=webide ;;
  esac
  [ X${#xf}Z = X0Z ] && return 0
  local exts=(
    ##basics
    mkhl.shfmt
    geeebe.duplicate
    editorconfig.editorconfig
    kennylong.kubernetes-yaml-formatter
  )
  printf $xf' --force --install-extension %s\n' ${exts[@]} | bash -x
}
##////////////////////////////////////////////////////////////////////////////##
shfn::custos::upt_chronyconfig() {
  ###
  [ X = X$(command -v chronyc) ] && exit 0
  ###
  { . /etc/os-release; } 2>/dev/null
  local keyword_service="chronyd"
  local config_chrony="/etc/chrony.conf"
  case ${ID,,} in
  debian | ubuntu) {
    keyword_service=chrony
    config_chrony=/etc/chrony/chrony.conf
    mkdir -p ${config_chrony%/*}
  } ;;
  esac
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  local postfix='#'
  local ntp_svr=${SHV_NTPSVR:-"ntp.tuna.tsinghua.edu.cn"}
  [ X24 = X${#ntp_svr} ] && postfix=
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  {
    echo "server ${ntp_svr} minpoll 4 maxpoll 10 iburst"
    echo "keyfile /etc/chrony/chrony.keys"
    echo "driftfile /var/lib/chrony/chrony.drift"
    echo "logdir /var/log/chrony"
    echo "maxupdateskew 100.0"
    echo "makestep 1 3"
    echo "rtcsync"
    echo "${postfix}local stratum 10"
    echo "${postfix}allow all"
  } 2>/dev/null | tee $config_chrony
  ##
  systemctl enable $keyword_service
  systemctl restart $keyword_service
}

##////////////////////////////////////////////////////////////////////////////##
shfn::custos::dotmyinit() {
  local thzmod_fullpath=${BASH_SOURCE%/*}
  ##---------------------------------------
  set -- $HOME/.myinit
  rm -rf $1 2>/dev/null
  cp -rf $thzmod_fullpath/*myinit $1
  ##---------------------------------------
  set -- $HOME/.config/nvim && mkdir -p ${1%/*} 2>/dev/null
  rm -rf $1 2>/dev/null
  cp -rf $thzmod_fullpath/*nvim $1
  ##---------------------------------------
  set -- $HOME/.config/pip/pip.conf && mkdir -p ${1%/*} 2>/dev/null
  install -m 644 $thzmod_fullpath/*others/tf*pipconf $1
  ##---------------------------------------
  install -m 644 $thzmod_fullpath/*others/tf*bashrc $HOME/.bashrc
  install -m 644 $thzmod_fullpath/*others/tf*profile $HOME/.profile
  install -m 644 $thzmod_fullpath/*others/tf*gitconfig $HOME/.gitconfig
  install -m 644 $thzmod_fullpath/*others/tf*editorconfig $HOME/.editorconfig
  ##---------------------------------------
  local vscdt_fullpath="$HOME/.vscode-server/data"
  set -- $vscdt_fullpath/Machine $vscdt_fullpath/User && mkdir -p $@ 2>/dev/null
  install -m 644 $thzmod_fullpath/*oth*/vf*-user-settings.json $2/settings.json
  install -m 644 $thzmod_fullpath/*oth*/vf*-machine-settings.json $1/settings.json
  install -m 644 $thzmod_fullpath/*oth*/vf*-machine-keybindings.json $1/keybindings.json
}
##////////////////////////////////////////////////////////////////////////////##
shfn::custos::allinit() {
  ##TASK-TYPE1: update-dotXXXX ###============================================##
  shfn::custos::dotmyinit
  shfn::custos::upt_dotssh
  ##TASK-TYPE2: IF-NOT-EXIST-THEN-DO-INSTALLATION ###=========================##
  [ X = X$(command -v jq) ] && shfn::istbin::jq
  [ X = X$(command -v nvim) ] && shfn::istbin::nvim
  [ X = X$(command -v shfmt) ] && shfn::istbin::shfmt

  ##TASK-TYPE3: IF-EXIST-THEN-DO-INSTALLATION ###=============================##
  [ X != X$(command -v sshd) ] && shfn::custos::upt_sshconfig
  [ X != X$(command -v chronyc) ] && shfn::custos::upt_chronyconfig
}
##////////////////////////////////////////////////////////////////////////////##
shfn::custos::upt_dotssh() {
  {
    local tpl_config='
    SG9zdCAqCiAgRm9yd2FyZFgxMSBubwogIEZvcndhcmRYMTFUcnVzdGVkIG5vCiAgU3RyaWN0SG9z
    dEtleUNoZWNraW5nIG5vCiAgSWRlbnRpdHlGaWxlIH4vLnNzaC9pZF9lZDI1NTE5CiAgVXNlcktu
    b3duSG9zdHNGaWxlIH4vLnNzaC9raHMtJWsKICBVc2VyIHJvb3QK'
    local tpl_pubkey='
    c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUF3N1F0RHhsKzJMTlRyT3lyb0w3
    Zy9Vd0Iwd0IwWU5Fd0psVW1vM1pGbjcgYWJvZHVAcXEuY29tCg=='
    local tpl_prikey='
    LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFB
    QUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUFNd0FBQUF0emMyZ3RaVwpReU5UVXhP
    UUFBQUNBTU8wTFE4WmZ0aXpVNnpzcTZDKzRQMU1BZE1BZEdEUk1DWlZKcU4yUlord0FBQUpCQy9S
    MnNRdjBkCnJBQUFBQXR6YzJndFpXUXlOVFV4T1FBQUFDQU1PMExROFpmdGl6VTZ6c3E2Qys0UDFN
    QWRNQWRHRFJNQ1pWSnFOMlJaK3cKQUFBRUROQWd3VXlOYlFiZDBZZjBXNTE3THJoRFl3cE53K3I2
    K3dTSll1R0QzeDNndzdRdER4bCsyTE5Uck95cm9MN2cvVQp3QjB3QjBZTkV3SmxVbW8zWkZuN0FB
    QUFER0ZpYjJSMVFIRnhMbU52YlFFPQotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K
    '
  } 2>/dev/null
  ###------------------------------------------------------------------------###
  set -- $HOME/.ssh && [ ! -d $1 ] && mkdir -p $1
  chmod 700 $1 && cd $1
  ###------------------------------------------------------------------------###
  {
    set -- config authorized_keys id_ed25519.pub id_ed25519
    echo "$tpl_config" | sed -r 's|\s+||' | base64 -d | tee $1
    echo "$tpl_pubkey" | sed -r 's|\s+||' | base64 -d | tee $2 | tee $3
    echo "$tpl_prikey" | sed -r 's|\s+||' | base64 -d | tee $4
  } 2>/dev/null
  ###------------------------------------------------------------------------###
  chmod 600 $@
}
##////////////////////////////////////////////////////////////////////////////##
shfn::custos::upt_sshconfig() {
  ###------------------------------------------------------------------------###
  ####ALLOW-ROOT-LOGIN####
  if [ X != X$(command -v sshd) ]; then
    set -- /etc/ssh/sshd_config.d
    if [ -d $1 ]; then
      ##add-new-files-into-$1
      echo 'PermitRootLogin yes' | tee $1/10-allow-root-login.conf
    else
      ##change /etc/ssh/sshd_config
      sed -r -i 's|^#?(PermitRootLogin) .*|\1 yes|' ${1%.d}
    fi
    ##restart-service-process
    for x in ssh sshd; do
      if [ XactiveZ = X$(systemctl is-active $x)Z ]; then
        systemctl enable $x
        systemctl restart $x
        break
      fi
    done
  fi
  ###------------------------------------------------------------------------###
  if [ X1 != X${SHV_UPT_SSHD:-0} ]; then
    local tpl_mycfg_sshd='
    H4sIAAAAAAAAA+1WbW/bNhDOZ/2KAwoMThc5slO7bYABdV2nCdq0huV2+xbQEi0xpkmNpJx4H/bb
    d0fJseJ0HTCgGAbo6Ysl8u54vHvuTtbm6U2i1VJkRz8KEWIYRf43evo7iPqDo94gOhtGw7Phi+FR
    1Ou9fBkdQfTDPGqgtI4ZgCOjtfue3D/t/0/x7Bn84vGWWZFAzJPSCLeFS2ZSroTKqt0A5d4JyxaS
    QxxfbnrB1GinEy2hT3ujDRPS7yru7rRZAYY1WVnoMLU9Fbjo/xseB6M0NdzaC7YWcgu0SPozbp0R
    iQMprPPnwtUUtWPugFk0ylOeHgcf/W5tAqKu/0P61zoVyy25BoU27onilBb7/SB4uO+odDlXTiTM
    Ca3gJxglCRkda+WMlvtrj6TUd0DpB6kzoYIpN2vhZrjwkd5hyy3JYUBysRAO+LrAABbMWgxEamv5
    Ca1Od4ugNOlM1FKbhMOKb8MFszwF9titTloHfWcOr1I/HVyg9mKiKvFyITGdaPfAYjAtF7j6beVf
    c+E4ZQBKy42FnzEJYOrUoNzThDzz0fnipWWagby9va9S7yP2pve63+0NX3Wfd58/PQAyo8vC1kbe
    +xewNg/96T6t7F6sy/VhVJhzFGQLBRrB5qW4dy9AcbrY3AhuK15WGXJizXWJrPi9FMkKaYdRrdWg
    VA3jmIC9OYt8I/X3hiV8jibgLGrGeDq6hrVOS3zsCOV4ZtAA3AmXwwVWQ/8tU8cBhobkKMB77k1U
    YraFv8pIZhoLLl9D7AxXGbnyzaq742wFbCdtT6Awgp7FHxzGOcO//QiYSmE0icP34+uKkg8ik7Q/
    GPReEyNscKmt+4DUOOUuOcWA07+bHBdveCV2g2K+LOOR1wCb61KmsODwIno9DInm2oBkJuPmO+aM
    Zd7UWBQ5USTJWUKOhoWW295ZNHijC65QvJvo9Qnjtj8YhlmyPlzu9V8dLgfXo7GFfM2S0KLJcNDr
    h9w91tzvkt2D3eADv3+IPrpWmg33l/cag+HJk5U3UixIWZvsBNvNUvAw51KumQo9k0N+j7dTGa/l
    GxmPsbVUbWb8wK+Hpkdc2yd8LAWyETsjw50N9eIV50XIpNhwqj9McfVcYJVxLAK2dFgGZ1EEliN7
    sbnoZUP9OKgsjkjpCnlqNkySOB02p96kiLd73tcG+7BEFmNFNI7fFV7T5FiXymHlVQVXt08yh/Ez
    dJPvVBh0rhTyk8nzGb/FtRkKnKOtYyrlGAezo5YwOB9E572obghN07YKa9UIqGt4vd3iWbPdpxum
    Ejyd5hY/jPmuyN59irHfbZCqHJu9XpUFdGguSO5r2/d/7IoFyeDxNG5ycYt5wJL1tU4Gqta+M4lM
    K0yd/c47vvT5y5hQ2ATHs6vrCQWVRiXmqSH62AgdxDI6EufFHY5mGpCdug9phR3tDgOMrmODM9SX
    fUcdkcbFXuGxzfl4Ws3Kb5i0eGOiD5fb2tY8KRqW6nmxM/Vbr4e9nBU5Zlg27AW48bfnf51+Alci
    FSRJVkNy7t9rwbj6IlgKmme0XUUmybn/sODdrHsCf552sSSxoRt0WBt0t1LDDwKcAbWfdNU9iwN8
    /YBvnr0HnRkbfkau4udAmSIzm514xqtTiAYWnAa7tfgYxP7ngiVCUrWOvswvG1MCybTQnk6V5c6c
    xkmddKxhrChTj5qPyCoJXyezt5/jyaOvovhiPq1nMp1b8EQscbzvbk3jrkND+NT3IVgzl+R02J4Q
    cblAd7F6wS5dATSvjGIy9G/h0nsNoYSrTxefg//6o7RFixYtWrRo0aJFixYtWrRo0aJFixYtWrRo
    0aJFixb/Cn8BYbfgPwAoAAA='
    #######################################
    echo "$tpl_mycfg_sshd" | sed -r 's,^\s+,,' | base64 -d |
      tar -C /etc/ssh/ -zxf -
  fi 2>/dev/null
}
