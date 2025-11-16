# 操作系统配置初始化

|缩写|含义|
|:--:|:--:|
|osci |**O**perating **S**ystem **C**onfiguration **I**nitialization|

## 一键下载代码并执行

```bash
## Ubuntu ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cfg1=/etc/apt/sources.list.d/ubuntu.sources
echo 'nameserver 114.114.114.114' >/etc/resolv.conf
sed -i -r '/^URIs:/s@.*@URIs: https://mirrors.ustc.edu.cn/ubuntu@' $cfg1
sed -i -r 's@//(archive|security)@//cn.archive@' /etc/apt/sources.list
apt-get update -y >/dev/null
apt-get install -y curl git make jq bash-completion tar gzip bzip2 gawk
git clone https://gitee.com/abldg/osci ~/0-osci && cd ~/0-osci && make

## OpenEuler ##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo 'nameserver 114.114.114.114' >/etc/resolv.conf
yum update -y
yum install -y curl git make jq bash-completion tar gzip bzip2 gawk
git clone https://gitee.com/abldg/osci ~/0-osci && cd ~/0-osci && make
```
