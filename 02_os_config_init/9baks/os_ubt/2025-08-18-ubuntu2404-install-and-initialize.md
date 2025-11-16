# Ubuntu24.04安装及初始化

## 1. 开始前的准备工作

[0]: #
[ventoy]: https://ghfast.top/https:/github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip
[ubuntu]: https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04.3/ubuntu-24.04.3-live-server-amd64.iso

>1. 下载Ventoy最新版: [从github下载ventoy-1.1.07-windows.zip][ventoy]
  解压后双击Ventoy2Disk.exe安装到U盘中即可
>1. 下载ISO镜像文件并拷贝到U盘根目录: [ubuntu24.04.3清华大学镜像下载链接][ubuntu]<br/>

## 2. 安装操作系统

按照提示一步一步执行安装操作即可, 这里仅说明几处需要修改的配置

>| 几处需要修改的配置 | 说明 |
>|:--|:---|
>| **Network configuration** | 禁用掉所有的网口配置, 安装完成后手动配置 |
>| **Storage configuration** | 去掉 LVM group 的勾选, 使用默认的硬盘分区方法 |
>| **SSH configuration** | 添加 Install OpenSSH Server 的勾选 |

出现完成安装的提示后, 拔下[**U盘**],后按回车键重启至新安装的操作系统

## 3. 操作系统初始化

> 输入登录用户及登录密码, 进入到系统<br/>
> 输入命令 [**sudo -i**][0] 并再次输入当前用户的登录密码切换到 [root][0] 用户

### 3.1 为服务器第一个网口设置可上网的IP

```bash
## 当前以[192.168.166.39]为例做演示，注意修改成实际的
ifns=($(ip link | awk -F': ' '$2~/^e[ntm].*/{print $2}'))
## 拉起网口1
ip link set dev $ifns up
## 添加IP
ip addr add 192.168.166.39/24 dev $ifns
## 添加默认网关
ip route add default via 192.168.166.1 dev $ifns
## 添加DNS
echo nameserver 114.114.114.114 >/etc/resolv.conf
```

>[验证][0]: **`ping www.qq.com`** 若是可以ping通，则说明网口配置正确。

### 3.2 修改 [root][0] 用户密码并允许 [root][0] 远程登录

```bash
## 假设root用户密码为: ljjx#123
echo 'root:ljjx#123' | chpasswd --

## 添加配置
mkdir -p /etc/ssh/sshd_config.d
echo 'PermitRootLogin yes' >/etc/ssh/sshd_config.d/10-allow-root-login.conf

## 重启ssh服务
systemctl daemon-reload
systemctl restart ssh
```

### 3.3 通过SSH远程到服务器上,修改apt源,并安装常用的软件包

```bash
## 使用清华的apt源
oid=$(. /etc/lsb-release && echo $DISTRIB_CODENAME)
bash -c 'cat > /etc/apt/sources.list.d/ubuntu.sources <<"EEE"
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: '"$oid $oid-updates $oid-backports $oid-security"'
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EEE'

## 更新列表并将软件包升级到最新
apt update -y && apt upgrade -y

## 安装常用的软件包
pkgs=(git gcc make gawk jq libffi-dev libssl-dev libdbus-glib-1-dev)
pkgs+=(python3-dev python3-venv python3-pip python3-docker python3-dbus)
apt install -y ${pkgs[@]}
```

### 3.4 更新 00_loclan.yaml 以固化第一个网口的IP及网关

```bash
ifns=($(ip link | awk -F': ' '$2~/^e[ntm].*/{print $2}'))
## 获取eno1口的IP及网关
ifn1_ip=$(ip -4 addr show dev $ifns | awk '/inet /{printf $2}')
ifn1_gw=$(ip -4 -j r get 1 | jq -r '.[0]|select(.gateway!=null)|.gateway')

## 删除旧配置
rm -f /etc/netplan/*.yaml 2>/dev/null

## 保存新配置
bash -c 'cat > /etc/netplan/00_loclan.yaml <<"EEE"
network:
  version: 2
  ethernets:
    '${ifns[1]}': { dhcp4: no, link-local: [] }
    '${ifns[0]}':
      dhcp4: no
      dhcp6: no
      addresses:
      - '${ifn1_ip}'
      routes:
      - { metric: 100, to: 0.0.0.0/0, via: '${ifn1_gw}' }
      nameservers:
        addresses: [ 223.5.5.5, 114.114.114.114, 8.8.8.8 ]
EEE' && chmod 600 /etc/netplan/00_loclan.yaml

## 更新[/etc/systemd/resolved.conf]
bash -c 'sed -r -i -e "/^#?DNS=/s@.*@DNS=114.114.114.114@" \
  -e "/^#?FallbackDNS=/s@.*@FallbackDNS=223.5.5.5@" \
  /etc/systemd/resolved.conf'

## 禁用 127.0.1.1 映射
sed -r -i '/^127.0.1.1/s@^@#@' /etc/hosts

## 使配置生效
netplan apply
```

### 3.5 问题修复[启动时等待网口拉起导致150s超时][0]

```bash
## 移除旧的配置
sed -i '/^TimeoutStartSec=/d' \
  /etc/systemd/system/network-online.target.wants/*.service

## 添加新的配置
sed -i '/^RemainAfterExit=yes/aTimeoutStartSec=2' \
  /etc/systemd/system/network-online.target.wants/*.service
```

### 3.6 禁用多余的服务及定时器

```bash
## 设置为多用户模式启动
systemctl set-default multi-user.target

## 禁用 CTRL-ALT-DEL 重启的快捷键
systemctl mask ctrl-alt-del.target

## 禁用 定时器
bash -c '[ -d ${TIMERSDIR:=/etc/systemd/system/timers.target.wants} ] && (
  cd $TIMERSDIR
  rm -f apt-daily* apport-autoreport.timer motd-news.timer
  rm -f update-notifier-* ua-timer.timer fwupd-refresh.timer
)'

## 禁用 多余的服务
bash -c '[ -d ${MUSRDIR:=/etc/systemd/system/multi-user.target.wants} ] && (
  cd $MUSRDIR
  rm -f apport.service lxd-installer.socket ufw.service
  rm -f ua-reboot-cmds.service unattended-upgrades.service
  rm -f ModemManager.service rsyslog.service secureboot-db.service
)'

## 移除软件包[cloud-init, snapd及needrestart]
bash -c '[ -d ${CLOUDIR:=/etc/cloud} ] && rm -rf $CLOUDIR;
  apt purge --auto-remove -y cloud-init snapd needrestart'
```

### 3.7 对指定IP的服务器设置ssh免密登录

```bash
##更新[~/.ssh/config]
bash -c 'cat > ~/.ssh/config <<"EEE"
Host *
  ForwardX11 no
  ForwardX11Trusted no
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/id_ed25519
  UserKnownHostsFile ~/.ssh/khs-%k
  User root
EEE'

##生成[~/.ssh/id_ed25519{,.pub}]
kfile=$HOME/.ssh/id_ed25519
[ ! -e $kfile ] && ssh-keygen -t rsa -N '' -f $kfile
cat $kfile.pub >~/.ssh/authorized_keys
ssh-copy-id -f 192.168.166.39
ssh-copy-id -f 192.168.166.38
ssh-copy-id -f 192.168.166.37
ssh-copy-id -f 192.168.166.36
ssh-copy-id -f 192.168.166.35
```

### 3.8 在所有的存储节点上创建vg卷
```bash
wipefs --all --force /dev/sdb

# 为 cinder 创建物理卷
pvcreate /dev/sdb

# 创建卷组
vgcreate cinder-volumes /dev/sdb

# 配置 LVM 过滤
bash -c 'tee /etc/lvm/lvm.conf << EOF
devices {
    filter = [ "a/sdb/", "r/.*/" ]
}
EOF'
```

## 4. Ubuntu24.04切换GPU的驱动为vfio-pci

### 4.1 设置[vfio-pci]驱动统管NVIDIA所有设备

```bash
## 获取所有的NVIDIA相关的设备列表
nvlst="$(lspci -nk | awk '/10de:(2206|1e04)/{print $3}' | sort -u)"

## 更新配置
cfile=/etc/modprobe.d/ljjx-nvidia-gpus-use-vfio-pci.conf
bash -c 'cat > '$cfile' <<"EEE"
##ADD-BY-LJJX
##append-into-blocklist
blacklist amd76x_edac
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
blacklist rivafb
blacklist rivatv
blacklist snd_hda_intel
blacklist vga16fb

##newadd-vfio
options vfio-pci ids='$nvlst'
EEE'
```

### 4.2 设置开机自动加载VFIO及KVM的驱动

```bash
## 更新配置
cfile=/etc/modules-load.d/ljjx-autoload-vfio-and-kvm.conf
bash -c 'cat > '$cfile' <<"EEE"
##ADD-BY-LJJX
kvm
kvm_intel
pci_stub
vfio
vfio_iommu_type1
vfio_pci
EEE'
```

### 4.3 更新文件[/etc/default/grub]并验证是否生效

```bash
## 添加 iommu=pt
newct='intel_iommu=on amd_iommu=on iommu=pt '
newct+='default_hugepagesz=1G hugepagesz=1G hugepages=8'
sed -r -i '/^GRUB_CMDLINE_LINUX_DEFAULT=""/s@="@="'"$newct"'@' /etc/default/grub

## 更新并重启
update-grub2 && reboot

## 验证 iommu=pt
grep iommu /proc/cmdline

## 验证 vfio_pci
lspci -nnk -d 10de:
```
