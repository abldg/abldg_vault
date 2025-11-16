[TOC]

### 安装incus以及优化配置

> 使用中科大的镜像仓库(<https://mirrors.ustc.edu.cn/incus/stable>)安装incus

#### 添加中科大镜像仓库并安装incus

```bash
fasc=/usr/share/keyrings/zabbly.asc
fcfg="/etc/apt/sources.list.d/zabbly-incus.sources" && {
  echo 'Types: deb'
  echo 'URIs: https://mirrors.ustc.edu.cn/incus/stable'
  echo 'Suites: noble'
  echo 'Components: main'
  echo 'Signed-By: '$fasc
} >$fcfg
curl -fsSL4o $fasc https://pkgs.zabbly.com/key.asc
ipkg="qemu-system zfsutils-linux"
ipkg+="incus incus-client incus-ui-canonical "
apt update -y && apt install -y $ipkg
systemctl enable incus --now
```

#### 更改images的remote镜像地址

```bash
####使用南京大学的镜像(清华的镜像因同步失败已失效)
murl="https://mirrors.nju.edu.cn/lxc-images/"
incus remote remove images
incus remote add images ${murl} --protocol=simplestreams --public
##test: create a ubuntu22.04 vm
incus launch images:ubuntu/22.04/amd64 ubt2204vm --vm
```

#### 集群化运行incus的初始化问答情况

```bash
Would you like to use clustering? (yes/no) [default=no]: yes  #---
What IP address or DNS name should be used to reach this server? [default=192.168.X.Y]:
Are you joining an existing cluster? (yes/no) [default=no]:
What member name should be used to identify this server in the cluster? [default=X-Y]:
Do you want to configure a new local storage pool? (yes/no) [default=yes]: no #---
Do you want to configure a new remote storage pool? (yes/no) [default=no]:
Would you like to use an existing bridge or host interface? (yes/no) [default=no]: yes
Name of the existing bridge or host interface: br0   #---
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]:
Would you like a YAML "init" preseed to be printed? (yes/no) [default=no]:
```

#### [可选]在 /dev/sdb 创建名字为 disks 的zfs存储池

```bash
incus storage create disks zfs source=/dev/sdb
```
