#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: get_service_port_from_xml.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================

get_port() {
  sed -n -r 's/\s+?<'$2'>([0-9]+)<\/'$2'>/\1/p' $1
}
get_port $1 service.port
get_port $1 service.management.port
