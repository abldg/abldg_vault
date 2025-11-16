#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: dkruns_01_mariadb.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================

dpswd=${SHV_DBPSWD:-'your_dbpswd'}
wkdir=/opt/dkruns/01_mariadb && mkdir -p $wkdir/{conf,data} 2>/dev/null
############################################
bash -c 'tee '$wkdir'/conf/mariadb.cnf <<"EEE"
[mysqld]
skip-name-resolve
expire_logs_days=30
innodb_file_per_table=ON
max_connections=300
max_allowed_packet=20M
default_time_zone='+00:00'
slow_query_log = ON
long_query_time = 30
slow_query_log_file = /var/log/mysql/slow.log
log_error = /var/log/mysql/mariadb.err.log
general_log_file=/var/log/mysql/mariadb.log
general_log=OFF
EEE' 2>/dev/null
############################################
bash -c 'tee '$wkdir'/compose.yaml <<"EEE"
services:
  mariadb:
    container_name: "mariadb_latest"
    # 使用指定的加速镜像地址
    image: rtf0h2092ed1um.xuanyuan.run/mariadb
    # 使用host网络模式,直接使用宿主机的网络
    network_mode: host
    # 容器总是重启
    restart: always
    # 环境变量配置
    environment:
      - MYSQL_ROOT_PASSWORD=your_rtpswd   # 替换为你的root密码
      - MYSQL_DATABASE=your_database      # 可选：初始化时创建的数据库
      - MYSQL_USER=your_user              # 可选：创建的用户
      - MYSQL_PASSWORD=your_usrpswd       # 可选：用户密码
    # 数据卷挂载,将数据持久化到当前目录的data文件夹
    volumes:
      - ./data:/var/lib/mysql
      - ./conf/mariadb.cnf:/etc/mariadb.cnf
    # 健康检查配置
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p$$MYSQL_ROOT_PASSWORD"]
      interval: 10s
      timeout: 5s
      retries: 5
EEE'
############################################
{
  (
    cd $wkdir && git init
    git add . -f && git commit -m 'init-mariadb'
  ) >/dev/null
  echo "在目录[$wkdir]中执行[ docker compose up -d ]命令启动mariadb服务"
} 2>/dev/null
