#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 02_registry.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-17 13:31:16
## VERS: 0.3
##==================================----------==================================
shfn::dkcrun::base::registry() {
  myt::new_compose_yml() {
    local tpl='services:
    #TDL#  RV_CTNM:
    #TDL#    image: docker.1ms.run/registry:3
    #TDL#    container_name: RV_CTNM
    #TDL#    hostname: RV_CTNM
    #TDL#    restart: unless-stopped
    #TDL#    networks:
    #TDL#      - RV_NTWK
    #TDL#    ports:
    #TDL#      - RV_PORT:5000
    #TDL#    volumes:
    #TDL#      - /etc/localtime:/etc/localtime:ro
    #TDL#      - RV_DATA:/var/lib/registry
    #TDL#    environment:
    #TDL#      - TZ=Asia/Shanghai
    #TDL#      - REGISTRY_STORAGE_DELETE_ENABLED=true  #允许删除镜像
    #TDL#      - REGISTRY_HTTP_ADDR=0.0.0.0:5000
    #TDL#    healthcheck:
    #TDL#      test: ["CMD","registry","-v"]
    #TDL#      interval: 10s
    #TDL#      timeout: 10s
    #TDL#      retries: 120
    #TDL#volumes:
    #TDL#  RV_DATA:
    #TDL#    name: RV_DATA
    #TDL#networks:
    #TDL#  RV_NTWK:
    #TDL#    name: RV_NTWK
    #TDL#    driver: bridge
    #TDL#'
    ######
    set -- registry ${SHV_PORT_REGISTRY:-"5000"}
    echo "$tpl" | sed -r -e "s@\s+#TDL#@@;s@RV_PORT@$2@" \
      -e "s@RV_CTNM@$1@;s@RV_DATA@mydata_$1@;s@RV_NTWK@myntwk_$1@"
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  : ${SHV_DKCBASE:="/opt/dpanel_projs"}
  : ${SHV_DKCYAML:="compose.yml"}
  local wrkdir=$SHV_DKCBASE/$(basename ${BASH_SOURCE%.sh})
  # return
  rm -rf $wrkdir 2>/dev/null
  mkdir -p $wrkdir && cd $wrkdir
  ##
  myt::new_compose_yml >$SHV_DKCYAML 2>/dev/null
  myt::ready::dkimg $(sed -rn 's|^\s+image: (.*)$|\1|p' $SHV_DKCYAML)
  [ X != X$SHV_RUN_NOW ] && (cd $wrkdir && docker compose up -d)
  {
    set -- $PWD/$SHV_DKCYAML
    echo -e "=[TIP]=>RUN-TASK: $(tput setaf 4)${1}$(tput sgr0)"
  } 2>/dev/null
}
