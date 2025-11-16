#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: mi_15_1panel.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
shfn::istbin::1panel() {
  myt::ready::alldeps() {
    aidx=${1:-0}
    alst=(amd64 arm64 armv7 ppc64le s390x riscv64)
    atmp=${alst[$aidx]} && [ X${#atmp} = X0 ] && atmp=${alst}
    ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
    burl=https://resource.fit2cloud.com/1panel/package/v2/stable
    [ X1 = X${SHV_USE_1PANEL_V1:-0} ] && burl=https://resource.1panel.pro/stable
    vern="$(curl -s $burl/latest)"
    if [ x0 = x${#vern} ]; then
      echo "Failed to obtain the latest version, please try again later"
      exit 1
    fi
    burl+=/$vern/release
    ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
    set -- $(curl -s $burl/checksums.txt | awk "/linux-${atmp}.tar.gz$/")
    [ $# -ne 2 ] && exit 1
    set -- $HOME/.cache/osci/$2 $1 $burl/$2 && mkdir -p ${1%/*} 2>/dev/null

    ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
    if [ -e $1 ]; then
      if [ X$2 = X$(sha256sum $1 | awk '{printf $1}') ]; then
        : "安装包已存在(哈希校验一致),跳过下载"
      else
        : "安装包已存在(哈希校验不一致),删除后开始重新下载"
        rm -f $1
      fi
    fi
    ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
    if [ ! -e $1 ]; then
      : "从地址 [$3] 下载安装包"
      while true; do
        curl -#4fSLo $1 $3
        if [ -e $1 ]; then
          [ X$2 = X$(sha256sum $1 | awk '{printf $1}') ] && break
          sleep 2 && rm -f $1
        fi
      done
      : "安装包下载成功(哈希校验一致)"
    fi
    {
      export TGZ_FILE=$1
      export LOCAL_IP=$(ip r get 1 | awk 'NR==1{print $(NF-2)}')
      export PANEL_PORT="1666"
      export PANEL_BASE_DIR=${PANEL_BASE_DIR:-/opt}
      export PANEL_ENTRANCE="ljjx1panel"
      export PANEL_PASSWORD="abc123456"
      export PANEL_USERNAME="admin"
      export SELECTED_LANG=${SELECTED_LANG:-zh}
    } 2>/dev/null
  }

  myt::do_installing() {
    _new::servicefile::1panel_xxxx() {
      {
        tpl='[Unit]
      TDL#Description=1Panel, a modern open source linux panel
      TDL#After=syslog.target network-online.target
      TDL#Wants=network-online.target
      TDL#
      TDL#[Service]
      TDL#ExecStart=/usr/local/bin/'"$1"'
      TDL#ExecReload=/bin/kill -s HUP $MAINPID
      TDL#Restart=always
      TDL#RestartSec=5
      TDL#LimitNOFILE=1048576
      TDL#LimitNPROC=1048576
      TDL#LimitCORE=1048576
      TDL#Delegate=yes
      TDL#KillMode=process
      TDL#
      TDL#[Install]
      TDL#WantedBy=multi-user.target
      TDL#'
        set -- /etc/systemd/system/$1.service
        echo "${tpl}" | sed -r 's|\s+TDL#||g' >$1 && chmod 644 $1
        printf '===<<<ok-update-file: [\e[32m %s \e[0m]>>>===\n' $1
      } 2>/dev/null
    }
    _upt::configs::1pctl() {
      if [ -f $PANEL_BASE_DIR/1panel/db/core.db ]; then
        if grep -q "^CHANGE_USER_INFO=" $1; then
          sed -r -i '/^CHANGE_USER_INFO=/s|=.*|=use_existing|' $1
        else
          sed -r -i '/^LANGUAGE=.*/a CHANGE_USER_INFO=use_existing' $1
        fi
      fi
      ####
      sed -r -i \
        -e "/^BASE_DIR=/s|=.*|=${PANEL_BASE_DIR}|g" \
        -e "/^ORIGINAL_PORT=/s|=.*|=${PANEL_PORT}|g" \
        -e "/^ORIGINAL_USERNAME=/s|=.*|=${PANEL_USERNAME}|g" \
        -e "/^ORIGINAL_PASSWORD=/s|=.*|=${PANEL_PASSWORD}|g" \
        -e "/^ORIGINAL_ENTRANCE=/s|=.*|=${PANEL_ENTRANCE}|g" \
        -e "/^LANGUAGE=/s|=.*|=${SELECTED_LANG}|g" \
        $1
      printf '===<<<ok-update-file: [\e[32m %s \e[0m]>>>===\n' $1
    }
    _tip::begining() {
      {
        tpl='
    #TDL# ██╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗
    #TDL#███║    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
    #TDL#╚██║ ██ ██████╔╝███████║██╔██╗ ██║█████╗  ██║
    #TDL# ██║    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
    #TDL# ██║    ██║     ██║  ██║██║ ╚████║███████╗███████╗
    #TDL# ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
    #TDL#'
        echo "$tpl" | sed -r 's@\s+#TDL#@@'
      } 2>/dev/null
    }
    _show::setup_result() {
      { . /usr/local/bin/lang/${SELECTED_LANG}.sh; } 2>/dev/null
      log() {
        { echo -e "\033[0;34m[1Panel Log]: $1 \033[0m"; } 2>/dev/null
      }
      log "================================================================"
      log
      log "$TXT_THANK_YOU_WAITING"
      log
      log "$TXT_BROWSER_ACCESS_PANEL"
      # log "$TXT_EXTERNAL_ADDRESS http://$PUBLIC_IP:$PANEL_PORT/$PANEL_ENTRANCE"
      log "$TXT_INTERNAL_ADDRESS http://$LOCAL_IP:$PANEL_PORT/$PANEL_ENTRANCE"
      log "$TXT_PANEL_USER $PANEL_USERNAME"
      log "$TXT_PANEL_PASSWORD $PANEL_PASSWORD"
      log
      log "$TXT_PROJECT_OFFICIAL_WEBSITE"
      log "$TXT_PROJECT_DOCUMENTATION"
      log "$TXT_PROJECT_REPOSITORY"
      log "$TXT_COMMUNITY"
      log
      log "$TXT_OPEN_PORT_SECURITY_GROUP $PANEL_PORT"
      log
      log "$TXT_REMEMBER_YOUR_PASSWORD"
      log
      log "================================================================"
    }
    ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
    _tip::begining
    cd $(mktemp -d -t 1panel.XXXXXX)
    tar --strip-components=1 -zxf $TGZ_FILE && bktempdir=$PWD
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    {
      systemctl stop 1panel-core 1panel-agent
      rm -rf /usr/local/bin/1p[ac]* /usr/bin/1p[ac]* #/opt/1panel
      mkdir -p /usr/local/bin /usr/bin
      ####
    } 2>/dev/null
    ###1panel-core###
    set -- 1panel-core && set -- $1 /usr/local/bin/$1 /usr/bin/$1
    install -m 755 $1 $2 && ln -sf $2 $3 && ln -sf $2 ${3%-core}
    ###1panel-agent###
    set -- 1panel-agent && set -- $1 /usr/local/bin/$1 /usr/bin/$1
    install -m 755 $1 $2 && ln -sf $2 $3
    ###1pctl###
    set -- 1pctl && set -- $1 /usr/local/bin/$1 /usr/bin/$1
    install -m 755 $1 $2 && ln -sf $2 $3
    _upt::configs::1pctl $2
    ###GeoIP.mmdb###
    set -- GeoIP.mmdb $PANEL_BASE_DIR/1panel/geo
    rm -rf $2 2>/dev/null
    mkdir -p $2
    install -m 644 $1 $2/$1
    ###lang###
    [ -d lang ] && cp -rf lang /usr/local/bin/lang
    ###1panel-xxx.service###
    set -- 1panel-core 1panel-agent
    _new::servicefile::1panel_xxxx $1
    _new::servicefile::1panel_xxxx $2
    systemctl daemon-reload
    systemctl enable --now $1 $2
    ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    _show::setup_result 2>/dev/null
    cd && rm -rf $bktempdir
  }

  myt::ready::alldeps ${SHV_PLAT_INDEX:-}
  myt::do_installing

}
