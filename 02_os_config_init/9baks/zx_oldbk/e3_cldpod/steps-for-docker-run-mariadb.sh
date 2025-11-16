#[1]# create-docker-daemon.json
mkdir -p /etc/docker /opt/dataroot/docker 2>/dev/null
bash -c 'cat >/etc/docker/daemon.json <<"EEE"
{
  "data-root": "/opt/dataroot/docker",
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.m.daocloud.io"
  ],
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "storage-driver": "overlay2",
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "info",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "features": {
    "buildkit": true
  }
}
EEE'

#[2]# install-docker
cnurl=https://linuxmirrors.cn/docker.sh
sedex='s@^SPONSOR=@xSPONSOR@;/^\s+change_docker_r/s@change@#change@'
bash <(curl -sSL $cnurl | sed -r "$sedex")

#[3]# pull-images-for-mariadb-latest
docker pull mariadb:latest

#[4]# create [docker-compose.yaml],root_passwd: [0neC1oudDB#]
dprojs=/opt/dkcprojs/p01_mariadb && mkdir -p $dprojs
cd $dprojs && mkdir -p z1_config z2_datart
bash -c 'cat >docker-compose.yaml <<"EEE"
services:
  mariadb:
    image: mariadb:latest
    restart: always
    hostname: mariadb
    container_name: mariadb
    privileged: true
    ports:
      - 3306:3306
    volumes:
      - /etc/localtime:/etc/localtime
      - ./z1_config:/etc/mysql/conf.d
      - ./z2_datart:/var/lib/mysql
    environment:
      TIME_ZONE: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: 0neC1oudDB#
EEE'

#[5]# create-cldpod.conf
bash -c 'cat >z1_config/cldpod.conf <<"EEE"
[mysqld]
skip-name-resolve
expire_logs_days=30
innodb_file_per_table=ON
max_connections=300
max_allowed_packet=20M
default_time_zone="+00:00"
slow_query_log = ON
long_query_time = 30
slow_query_log_file = /var/log/mariadb/slow.log
log_error = /var/log/mariadb/mariadb.err.log
general_log=OFF
general_log_file=/var/log/mariadb/mariadb.log
EEE'

#[6]# run dockerfized-service [mariadb]
docker compose up -d

#[7]# grant root-user-remote-login
docker exec -it mariadb bash
mariadb -uroot -p # to-input-password: '0neC1oudDB#'
#copy-command-of-nextline,then-press-enter
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '0neC1oudDB#';FLUSH PRIVILEGES;
