[TOC]

### 优化 Ubuntu24.04 设置

> 使用 [Ubuntu-24.04-live-server.iso][link1] 安装操作系统,并设置可访问互联网

#### 设置成多用户模式并禁用CTRL-ALT-DEL

```bash
systemctl set-default multi-user.target && systemctl mask ctrl-alt-del.target
```

#### 配置systemd-resolved

```bash
fcfg="/etc/systemd/resolved.conf"
mdns="DNS=114.114.114.114" fdns="FallbackDNS=223.5.5.5"
sed -i -r -e '/^#?FallbackDNS=/s@.*@'$fdns'@' -e '/^#?DNS=/s@.*@'$mdns'@' $fcfg
systemctl restart systemd-resolved
```

#### 设置中科大apt镜像源

```bash
fcfg="/etc/apt/sources.list.d/ubuntu.sources" && {
  echo 'Types: deb'
  echo 'URIs: https://mirrors.ustc.edu.cn/ubuntu/'
  echo 'Suites: noble noble-updates noble-backports noble-security'
  echo 'Components: main restricted universe multiverse'
  echo 'Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg'
} >$fcfg && apt update -y
```

#### 安装常用软件包及移除snapd等

```bash
apt purge --auto-remove -y snapd needrestart open-vm-tools
ipkgs=" jq git make curl sudo tree sshfs unzip"
ipkgs+=" dos2unix lrzsz pciutils ipcalc bridge-utils"
ipkgs+=" uidmap net-tools openssh-server bash-completion"
apt install -y $instpkgs
```

#### 修改root密码及优化ssh配置

```bash
newpswd="example-for-new-pswd"
echo "root:$newpswd" | chpasswd --
fcfg="/etc/ssh/sshd_config.d/01-ljjx-ssh.conf" && {
  printf '##allow-root-login\nPermitRootLogin yes\n'
  printf '\n##fasten-ssh-login\nUseDNS no\n'
  printf '\n##allow-forwarding\n'
  printf 'Allow%sForwarding yes\n' Agent Tcp
} >$fcfg && systemctl enable ssh && systemctl restart ssh
```

#### 禁用cloud-init设置网络

```bash
fcfg=/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo 'network: {config: disabled}' >$fcfg
```

#### 修复网口拉起失败需要等待2min超时

```bash
fdir="/etc/systemd/system/network-online.target.wants"
sed -i -r '/^TimeoutStartSec=/d' $fdir/*.service
sed -i -r '/^RemainAfterExit=yes/aTimeoutStartSec=2' $fdir/*.service
```

#### 根据当前IP地址更新hostname

```bash
cur_ip=$(hostname -I)
[ X != "X${cur_ip}" ] && {
  new_hn=${cur_ip//./-} && hostnamectl set-hostname $new_hn
  echo "$cur_ip $new_hn" | tee -a /etc/hosts
}
```

#### 禁用nouveau并设置nvidia-smi
```bash
fcfg="/etc/modprobe.d/blacklist-nouveau.conf"
printf 'blacklist nouveau\noptions nouveau modeset=0\n' >$fcfg
bfile="/usr/bin/nvidia-smi" kfile="/etc/profile.d/z96-nvidia-smi-pm-1.sh"
echo "[ -x $bfile ] && $bfile -pm 1 &>/dev/null" >$kfile
```

#### 使用git管理目录 /etc

```bash
[ ! -d /etc/.git ] && (
  cd /etc; git init; git add . -f
  git config user.name supda && git config user.email "supda@lolsvr.mgr"
  git commit -m "init-at-$(date +%s)"
)
```

<!-- [[links]] -->
[link1]: https://mirrors.sdu.edu.cn/ubuntu-releases/24.04.2/ubuntu-24.04.2-live-server-amd64.iso
