#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 03_mysql.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-11-10 14:17:32
## VERS: 0.1
##==================================----------==================================

shfn::dkcrun::base::mysql() {
  set -- ${BASH_SOURCE##*/}
  set -- /opt/dkcrun/${1%*.sh}
  rm -rf $1 2>/dev/null
  mkdir -p $1/conf/init && cd $1
  #################################################
  local dbpswd=${CE_MYSQL_PASSWORD:-'woaini123'}
  #################################################
  {
    local tpl_mycnf='
    H4sIAAAAAAAAA+3TQW+bMBQA4Jz5FZV26GFLAyRh2SQfksAqpAUkQidtU/XkgJNYAZzZJqX99TMk
    jbpNWk/RNOl9EgL7Gds8P5qmudGN7l2SbXijUXc3fr87w6HXc8b2e892Pdf2erbjOONh78q+6K5O
    aqWpvLrqSSH+moXX4v+p7+Wj+lHk91ZONc25JIMDlYOCrwZdwMrZmtaF7mteMngSFSNvJx9t+9yv
    tJB0w/qs2nATDKMo9mdWtqWSZppJUEybSx6YJLVeT8rVyCrEgwlkVDHQdFUwqGjJFHGsY0vsWWWi
    2ZYRx51YJW0gE1XFMs1FpYhrKuZlJzAphVTEa/t5VYl8BWtu5tmbRboZzcyn/lW9XpvevRAFKP5k
    IrfdVLRo95TDnmY7pok3Wlha0krRbk3gShS0fSJJMPX783ixCNM08M/LFbXaQsn0VuQkBj9Mgnn6
    HCxEtoMHyjW0KRS1Js7kxU67VwuxAWoGyParypJrYlvqscpgxSsTM603hnVsAWv2XLL2JWVSa9KQ
    m6yMP7invJxGPX+fOUQoRc7I9TJNwnkKaTKNlpBOZ5+D5bsohm9BEkMYgT9Ng3O7awRJEifwyVx+
    +CVchnEEs69dvB0XRLdhFMDybrZMw/QuNeFrS+34vt+eZ18yk7UD++P8nPacfsmHO2kTYh0r8f5c
    Weca6psaOhfPadjNsaZeG/2v/y6EEEIIIYQQQgghhBBCCCGEEEIIIYQu6yf1dH6iACgAAA=='
    echo "$tpl_mycnf" 2>/dev/null | sed -r 's|\s+||g' | base64 -d | tar -Ozxf -
  } >conf/my.cnf 2>/dev/null
  #################################################
  {
    local tpl_initsql='-- create-database:[ce]
    D#CREATE DATABASE `RV_DBNAME` DEFAULT CHARACTER SET utf8mb4 COLLATE RV_CS;
    D#
    D#-- allow-[root]-login-from-[anyhost]
    D#ALTER USER RV_HID IDENTIFIED WITH mysql_native_password BY "RV_DBPSWD";
    D#GRANT ALL PRIVILEGES ON *.* TO RV_HID WITH GRANT OPTION;
    D#FLUSH PRIVILEGES;'
    ###
    echo "${tpl_initsql}" 2>/dev/null | sed -r -e 's|\s+D#||g' \
      -e "s|RV_CS|utf8mb4_general_ci|" \
      -e "s|RV_HID|'root'@'%'|" \
      -e "s|RV_DBNAME|ce|" \
      -e "s|RV_DBPSWD|$dbpswd|"
  } >conf/init/init.sql 2>/dev/null
  #################################################
  {
    local tpl='services:
    #TDL#  RV_CTNM:
    #TDL#    image: RV_IMG_ID
    #TDL#    container_name: RV_CTNM
    #TDL#    hostname: RV_CTNM
    #TDL#    restart: unless-stopped
    #TDL#    volumes:
    #TDL#      - ./conf/init/:/docker-entrypoint-initdb.d/
    #TDL#      - ./conf/my.cnf:/etc/my.cnf
    #TDL#      - ./logs:/var/log/mysql
    #TDL#      - /etc/localtime:/etc/localtime:ro
    #TDL#      - /tmp:/tmp
    #TDL#      - RV_DATA:/var/lib/mysql
    #TDL#    environment:
    #TDL#      - TZ=Asia/Shanghai
    #TDL#      - MYSQL_ROOT_PASSWORD=${CE_MYSQL_PASSWORD:-'"${dbpswd}"'}
    #TDL#    network_mode: host
    #TDL#    healthcheck:
    #TDL#      test: ["CMD","mysqladmin", "ping", "-uroot", "-p'${dbpswd}'"]
    #TDL#      interval: 10s
    #TDL#      timeout: 10s
    #TDL#      retries: 120
    #TDL#    deploy:
    #TDL#      resources:
    #TDL#        limits:
    #TDL#          memory: RV_MEMLMT
    #TDL#volumes:
    #TDL#  RV_DATA:
    #TDL#    name: RV_DATA
    #TDL#'
    ######
    : ${SHV_CE_REPO:=docker.1ms.run/}
    local ct_name="mysql"
    local ct_port=${SHV_PORT_MYSQL:-3306}
    local ct_imgid=mysql:${CE_MYSQL_VERSION:-"8.0"}
    local sed_exps=(
      -e 's|\s+#TDL#||'
      -e "s|RV_CTNM|$ct_name|"
      -e "s|RV_PORT|$ct_port|"
      -e "s|RV_DATA|mydata_$ct_name|"
      -e "s|RV_NTWK|dbntwk|"
      -e "s|RV_IMG_ID|${SHV_CE_REPO}$ct_imgid|"
      -e "s|RV_MEMLMT|${CE_MYSQL_MEMORY_LIMIT:-1G}|"
    )
    ######
    echo "$tpl" | sed -r ${sed_exps[@]} >${SHV_DKCYAML:-compose.yml}
  } 2>/dev/null
  #################################################
  [ X != X${SHV_RUN_NOW} ] && docker compose up -d && {
    set -- $(ip r get 1 | awk 'NR==1{print $(NF-2)}') $ct_port
    echo -e "=[TIP]=>MYSQL客户端访问地址 ${CGRN}$1:$2${CEND}"
  } 2>/dev/null
}
