#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 01_filesvr.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-17 11:38:28
## VERS: 0.2
##==================================----------==================================
shfn::dkcrun::base::filesvr() {
  myt::new_compose_yml() {
    local tpl='services:
    #TDL#  RV_CTNM:
    #TDL#    image: docker.1ms.run/nginx:alpine
    #TDL#    container_name: RV_CTNM
    #TDL#    hostname: RV_CTNM
    #TDL#    restart: unless-stopped
    #TDL#    networks:
    #TDL#      - RV_NTWK
    #TDL#    ports:
    #TDL#      - RV_PORT:80
    #TDL#    volumes:
    #TDL#      - /etc/localtime:/etc/localtime:ro
    #TDL#      - /opt/myfiles:/usr/share/nginx/html
    #TDL#      - ./conf/fs_01.conf:/etc/nginx/conf.d/default.conf
    #TDL#      - ./conf/fs_02.conf:/etc/nginx/nginx.conf
    #TDL#    healthcheck:
    #TDL#      test: ["CMD", "curl", "-s","127.0.0.1:80"]
    #TDL#      interval: 10s
    #TDL#      timeout: 10s
    #TDL#      retries: 120
    #TDL#    environment:
    #TDL#      - TZ=Asia/Shanghai
    #TDL#networks:
    #TDL#  RV_NTWK:
    #TDL#    name: RV_NTWK'
    ######
    set -- filesvr ${SHV_PORT_FILESVR:-18000}
    echo "$tpl" | sed -r -e 's@\s+#TDL#@@' \
      -e "s@RV_CTNM@$1@;s@RV_NTWK@myntwk_$1@;s@RV_PORT@$2@"
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  myt::new_fs01_conf() {
    local tpo='server {
    TDL#    listen 80;
    TDL#    server_name localhost;
    TDL#    root /usr/share/nginx/html;
    TDL#    index index.html index.htm;
    TDL#
    TDL#    # 启用目录浏览功能
    TDL#    autoindex on;
    TDL#    # 显示文件大小的单位,默认为bytes
    TDL#    autoindex_exact_size off;
    TDL#    # 显示本地时间而非GMT时间
    TDL#    autoindex_localtime on;
    TDL#    # 显示目录浏览的标题
    TDL#    autoindex_format html;
    TDL#
    TDL#    # 设置字符编码
    TDL#    charset utf-8;
    TDL#
    TDL#    # 日志配置
    TDL#    access_log /var/log/nginx/access.log;
    TDL#    error_log /var/log/nginx/error.log;
    TDL#}
    TDL#'
    echo "${tpo}" | sed -r 's|\s+TDL#||g'
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  myt::new_fs02_conf() {
    local tpo='pid  /run/nginx.pid;
    TDL#user nginx;
    TDL#error_log /var/log/nginx/error.log notice;
    TDL#worker_processes 2;
    TDL#
    TDL#events {
    TDL#    worker_connections  64;
    TDL#}
    TDL#
    TDL#http {
    TDL#    keepalive_timeout  65;
    TDL#    default_type application/octet-stream;
    TDL#    log_format   main  RV_LOGFMT;
    TDL#    access_log   /var/log/nginx/access.log  main;
    TDL#    sendfile     on;
    TDL#    #tcp_nopush  on;
    TDL#    #gzip        on;
    TDL#    include      /etc/nginx/mime.types;
    TDL#    include      /etc/nginx/conf.d/*.conf;
    TDL#}
    TDL#'
    local fmt='$remote_addr - $remote_user [$time_local] "$request" '
    fmt+='$status $body_bytes_sent "$http_referer" '
    fmt+='"$http_user_agent" "$http_x_forwarded_for"'
    echo "${tpo}" | sed -r -e 's|\s+TDL#||g' -e 's|RV_LOGFMT|'"'$fmt'"'|'
  }
  ###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~###
  : ${SHV_DKCBASE:="/opt/dpanel_projs"}
  : ${SHV_DKCYAML:="compose.yml"}
  : ${SHV_PORT_FILESVR:="18000"}
  local wrkdir=$SHV_DKCBASE/$(basename ${BASH_SOURCE%.sh})
  # return
  rm -rf $wrkdir 2>/dev/null
  {
    mkdir -p $wrkdir/conf && cd $wrkdir
    ##
    myt::new_fs01_conf >conf/fs_01.conf 2>/dev/null
    myt::new_fs02_conf >conf/fs_02.conf 2>/dev/null
    ##
    : $PWD/$SHV_DKCYAML
    myt::new_compose_yml >$SHV_DKCYAML 2>/dev/null
    myt::ready::dkimg $(sed -rn 's|^\s+image: (.*)$|\1|p' $SHV_DKCYAML)
  }
  [ X != X$SHV_RUN_NOW ] && (cd $wrkdir && docker compose up -d)
  {
    set -- http://$(ip r get 1 | awk 'NR==1{print $(NF-2)}'):${SHV_PORT_FILESVR}
    echo -e "=[TIP]=>页面访问地址 $(tput setaf 4)${1}$(tput sgr0)"
  } 2>/dev/null
}
