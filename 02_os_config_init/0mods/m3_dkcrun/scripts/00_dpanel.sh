#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 00_dpanel.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-17 10:08:32
## VERS: 0.1
##==================================----------==================================
shfn::dkcrun::base::dpanel() {
  myt::new_compose_yml() {
    local tpl='services:
    #TDL#  RV_CTNM:
    #TDL#    image: docker.1ms.run/dpanel/dpanel:lite
    #TDL#    container_name: RV_CTNM
    #TDL#    hostname: RV_CTNM
    #TDL#    restart: unless-stopped
    #TDL#    networks:
    #TDL#      - RV_NTWK
    #TDL#    ports:
    #TDL#      - RV_PORT:8080
    #TDL#    volumes:
    #TDL#      #- /opt/cloudexplorer/.env:/opt/cloudexplorer/.env
    #TDL#      - /var/run/docker.sock:/var/run/docker.sock
    #TDL#      - RV_WDIR:/dpanel/compose
    #TDL#      - RV_DATA:/dpanel
    #TDL#    environment:
    #TDL#      - APP_NAME=RV_CTNM
    #TDL#      - INSTALL_USERNAME=admin
    #TDL#      - INSTALL_PASSWORD=admin
    #TDL#    healthcheck:
    #TDL#      test: ["CMD", "wget", "--spider", "http://127.0.0.1:8080"]
    #TDL#      interval: 30s
    #TDL#      timeout: 10s
    #TDL#      retries: 3
    #TDL#      start_period: 10s
    #TDL#volumes:
    #TDL#  RV_DATA:
    #TDL#    name: RV_DATA
    #TDL#networks:
    #TDL#  RV_NTWK:
    #TDL#    name: RV_NTWK'
    ######
    set -- dpanel ${wrkdir%/*} ${SHV_PORT_DPANEL}
    echo "$tpl" | sed -r -e 's@\s+#TDL#@@' \
      -e "s@RV_CTNM@$1@" \
      -e "s@RV_DATA@${1}_data@" \
      -e "s@RV_NTWK@${1}_ntwk@" \
      -e "s@RV_WDIR@$2@" \
      -e "s@RV_PORT@$3@"
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  : ${SHV_DKCBASE:="/opt/dpanel_projs"}
  : ${SHV_DKCYAML:="compose.yml"}
  : ${SHV_PORT_DPANEL:="18080"}
  local wrkdir=$SHV_DKCBASE/$(basename ${BASH_SOURCE%.sh})
  # return
  rm -rf $wrkdir 2>/dev/null
  {
    mkdir -p $wrkdir && cd $wrkdir
    ##
    : $PWD/$SHV_DKCYAML
    myt::new_compose_yml >$SHV_DKCYAML 2>/dev/null
    myt::ready::dkimg $(sed -rn 's|^\s+image: (.*)$|\1|p' $SHV_DKCYAML)
  }
  # [ X != X$SHV_RUN_NOW ] && (cd $wrkdir && docker compose up -d)
  (cd $wrkdir && docker compose up -d)
  {
    set -- http://$(ip r get 1 | awk 'NR==1{print $(NF-2)}'):${SHV_PORT_DPANEL}
    echo -e "=[TIP]=>页面访问地址 $(tput setaf 4)${1}$(tput sgr0)"
  } 2>/dev/null
}
