[TOC]

## 基于incus安装microcloud集群

### 1-安装incus

点击跳转到 [ubuntu2404安装incus](01-install-incus-on-ubuntu-2404-lts.md)

### 2-创建存储磁盘

1. 在硬盘/dev/sdb上创建ZFS存储池disks,并附加disks到用户配置default中

```bash
incus storage create disks zfs source=/dev/sdc
incus profile device add default root disk path=/ pool=disks
```

2. 设定disks池的卷大小为40G

```bash
incus storage set disks volume.size 40GiB
```

3. 创建4块用于本地存储的磁盘以及3块磁盘用于远端存储

```bash
xcmd='incus storage volume create disks'
printf "${xcmd} local%d --type block;" 1 2 3 4 | bash -x
printf "${xcmd} remote%d --type block size=50GiB;" 1 2 3 | bash -x
```

4. 检查磁盘是否正确创建

```bash
incus storage volume list disks
```

### 3-创建网络

创建一个不带任何参数的桥接网络microbr0,获取并记录microbr0的IPv4地址

```bash
incus network create microbr0
incus network get microbr0 ipv4.address
incus network get microbr0 ipv6.address
```

### 4-创建并配置作为MicroCloud集群成员的虚拟机`microX`

1. 创建4个虚拟机microX但不启动它们

```bash
xcmd=' images:ubuntu/22.04/amd64'
xcmd+=' micro%d --vm'
xcmd+=' --config limits.cpu=2'
xcmd+=' --config limits.memory=2GiB'
printf "incus create ${xcmd};" 1 2 3 4 | bash -x
```

2. 将之前所创建的4块本地盘及3块远端盘附加到虚拟机

```bash
xcmd='x=%d && incus storage volume attach disks '
printf "${xcmd}"'local$x micro$x\n' 1 2 3 4 | bash -x
printf "${xcmd}"'remote$x micro$x\n' 1 2 3 | bash -x
```

3. 为每个虚拟机创建专用于MicroCloud网络的网络接口eth1

```bash
# xcmd='incus config device remove micro%d eth1;'
xcmd='incus config device add micro%d eth1 nic network=microbr0;'
printf "${xcmd}" 1 2 3 4 | bash -x
```

4. 启动所有的虚拟机

```bash
printf 'incus start micro%d\n' 1 2 3 4 | bash -x
#printf 'incus stop micro%d\n' 1 2 3 4 | bash -x
```

### 5-安装`MicroCloud`到每个虚拟机

> [需要在每个虚拟机上完成以下的步骤](#)

1. 以micro1为例,通过screen窗口ssw1访问其中的shell

```bash
screen -4mS ssw1 incus exec micro1 -- bash
```

2. 添加网口`eth1`的netplan配置

```bash
##因为MicroCloud需要一个没有分配IP地址的网络接口,所以配置并启用
##连接到microbr0的网络接口(通常为enp6s0),使其不接受任何IP地址
fyml='/etc/netplan/99-microcloud.yaml'
{
  echo '# MicroCloud requires a network interface that does not have an IP address'
  echo 'network:'
  echo '  version: 2'
  echo '  ethernets:'
  echo '    enp6s0:'
  echo '      accept-ra: false'
  echo '      dhcp4: false'
  echo '      link-local: []'
} > $fyml
chmod 0600 $fyml && netplan apply
```

3. 尝试安装snapd及所需的snaps,并配置hold

```bash
[ X = X$(command -v snap) ] && apt install -y snapd
snap install snap-store-proxy snap-store-proxy-client
snap install lxd        --cohort="+" --channel=5.21/stable
snap install microovn   --cohort="+" --channel=24.03/stable
snap install microceph  --cohort="+" --channel=squid/stable
snap install microcloud --cohort="+" --channel=2/stable
snap refresh --hold lxd microceph microovn microcloud

##在键盘上输入[exit],停止并退出screen窗口ssw1
```

### 6-初始化`MicroCloud`集群

```bash
#(1)输入下面的命创建screen窗口ssw1以启动MicroCloud初始化过程
screen -4mS ssw1 incus exec micro1 microcloud init
#(2)回答以下问题
# a. 选择[yes]以选择多个集群成员
# b. 作为 MicroCloud 内部流量的地址，选择列出的 IPv4 地址
# c. 复制[会话密码]
# d. 前往其他服务器（micro2、micro3 和 micro4）并开始它们的加入过程
#####在键盘上依次按下[Ctrl A D]使ssw1窗口后台运行
#####输入下面的命创建screen窗口ssw2启动虚拟机micro2加入集群的步骤
screen -4mS ssw2 incus exec micro2 microcloud join
#####回答问题,粘贴会话密码,等待完成加入集群过程
#####在键盘上依次按下[Ctrl A D]使ssw2窗口后台运行
#####输入下面的命进入screen窗口ssw3启动虚拟机micro3加入集群的步骤
screen -4mS ssw3 incus exec micro3 microcloud join
#####回答问题,粘贴会话密码,等待完成加入集群过程
#####在键盘上依次按下[Ctrl A D]使ssw3窗口后台运行
#####输入下面的命进入screen窗口ssw4启动虚拟机micro4加入集群的步骤
screen -4mS ssw4 incus exec micro4 microcloud join
#####回答问题,粘贴会话密码,等待完成加入集群过程
#####在键盘上依次按下[Ctrl A D]使ssw4窗口后台运行
#####输入下面的命恢复到screen窗口ssw1,继续虚拟机micro1上的问答
screen -r ssw1
# e. [勾选]所有列出的服务器(micro2, micro3 和 micro4)
# f. 选择[yes]以设置本地存储盘
# g. [勾选]所有列出的本地存储盘(local1, local2, local3 和 local4)
# h. [不勾选]任一个本地存储盘以跳过擦除操作过程(因为才刚刚创建了它们)
# i. 选择[yes]以设置分布式存储
# j. 选择[yes]以确认磁盘数量少于机器数量
# k. [勾选]所有列出的远端存储盘(remote1, remote2 和 remote3)
# l. [不勾选]任一个远端存储盘以跳过擦除操作过程(因为才刚刚创建了它们)
# m. 选择[no]以不需加密任何磁盘
# n. 选择[yes]以可选配置CephFS分布式文件系统
# o. 留空问题以使用 Ceph 内部网络的 IPv4 或 IPv6 CIDR 子网地址
# p. 留空问题以使用 Ceph 公共网络的 IPv4 或 IPv6 CIDR 子网地址
# q. 选择[yes]以配置分布式网络
# r. [勾选]所有列出的网络接口(每个虚拟机上的 enp6s0)
# s. 指定已记录的用于microbr0网络的IPv4地址作为IPv4网关: 
# t. 指定地址范围的起始地址(需要与网段在同一网段):
# u. 指定地址范围的结束地址(需要与网段在同一网段):
# v. 留空问题以配置用于分布式网络的DNS地址
# w. 留空问题以配置 OVN 的底层网络
```

[> 查看MicroCloud集群初始化问答记录](./txtdirs/00-microcloud-init-on-micro1.txt)


### 7-检查MicroCloud集群设置

> [在哪台虚拟机都可以执行检查命令, 继续在`micro1`上执行](#)

1. 检查集群设置

```bash
lxc cluster list
microcloud cluster list
microceph cluster list
microovn cluster list
```

[> 查看集群设置检查结果](./txtdirs/01-check-clust-setup.txt)

2. 检查存储设置

```bash
lxc storage list
lxc storage info local
lxc storage info remote
lxc storage info remote-fs
```

[> 查看存储设置检查结果](./txtdirs/02-check-storage.txt)

3. 检查OVN网络设置

```bash
lxc network list
lxc network show default
```

[> 查看OVN网络设置检查结果](./txtdirs/03-check-ovn-network.txt)

4. 确保可在`OVN`中`ping`虚拟路由器

```bash
lxc network list
lxc network show default
```

[> 查看OVN网络设置检查结果](./txtdirs/03-check-ovn-network.txt)
