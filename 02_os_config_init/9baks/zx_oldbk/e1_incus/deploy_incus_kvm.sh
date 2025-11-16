#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: deploy_incus_kvm.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
#!/bin/bash

# Incus KVM 生产环境部署脚本
# 适用于 Ubuntu 22.04+ 系统

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "此脚本必须以root用户运行"
    exit 1
  fi
}

# 系统要求检查
check_system_requirements() {
  log_info "检查系统要求..."

  # 检查操作系统
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" || ! "$VERSION_ID" =~ ^(22|24). ]]; then
      log_warn "推荐使用 Ubuntu 22.04/24.04 LTS 系统"
    fi
  fi

  # 检查内存
  total_mem=$(free -g | awk '/^Mem:/{print $2}')
  if [[ $total_mem -lt 8 ]]; then
    log_warn "系统内存小于8GB,可能影响性能"
  fi

  # 检查磁盘空间
  root_free=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
  if [[ $root_free -lt 50 ]]; then
    log_warn "根分区可用空间小于50GB"
  fi

  # 检查CPU核心数
  cpu_cores=$(nproc)
  if [[ $cpu_cores -lt 2 ]]; then
    log_warn "CPU核心数小于2,可能影响性能"
  fi

  # 检查KVM支持
  if ! grep -E -q 'vmx|svm' /proc/cpuinfo; then
    log_error "CPU不支持硬件虚拟化,无法运行KVM虚拟机"
    exit 1
  fi

  # 检查KVM模块
  if ! lsmod | grep -q kvm; then
    log_warn "KVM内核模块未加载"
    read -p "是否尝试加载KVM模块? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      modprobe kvm
      if [[ $? -ne 0 ]]; then
        log_error "无法加载KVM模块,请确保BIOS中启用了虚拟化技术"
        exit 1
      else
        log_info "KVM模块已成功加载"
      fi
    else
      log_error "KVM模块未加载,无法继续"
      exit 1
    fi
  fi

  log_info "系统检查完成"
}

# 安装依赖
install_dependencies() {
  log_info "安装依赖包..."
  apt update
  apt install -y qemu-kvm libvirt-clients libvirt-daemon-system \
    bridge-utils virt-manager libguestfs-tools cloud-image-utils \
    uidmap jq software-properties-common apt-transport-https \
    ca-certificates curl gnupg
  log_info "依赖包安装完成"
}

# 安装Incus
install_incus() {
  log_info "安装Incus..."

  # 添加Incus仓库
  add-apt-repository -y ppa:incus-developers/ppa

  # 安装Incus
  apt update
  apt install -y incus

  log_info "Incus安装完成"
}

# 配置系统参数
configure_system() {
  log_info "配置系统参数..."

  # 配置桥接网络
  cat >/etc/modules-load.d/bridge.conf <<EOF
bridge
br_netfilter
EOF

  # 设置桥接网络过滤规则
  cat >/etc/sysctl.d/99-kvm.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

  # 应用sysctl参数
  sysctl --system

  log_info "系统参数配置完成"
}

# 配置存储池
configure_storage() {
  log_info "配置存储池..."

  # 检测可用磁盘
  log_info "可用磁盘列表:"
  lsblk -d -o NAME,SIZE,TYPE | grep "disk"

  read -p "请输入用于存储池的磁盘设备名 (例如: sdb): " disk_device

  if [[ ! -b "/dev/$disk_device" ]]; then
    log_error "设备 /dev/$disk_device 不存在"
    exit 1
  fi

  # 创建ZFS存储池
  read -p "使用ZFS作为存储后端? [Y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    # 使用BTRFS
    log_info "创建BTRFS存储池..."
    incus storage create default btrfs source=/dev/$disk_device
  else
    # 安装ZFS
    apt install -y zfsutils-linux

    # 创建ZFS存储池
    log_info "创建ZFS存储池..."
    incus storage create default zfs source=/dev/$disk_device

    # 设置ZFS压缩
    zfs set compression=lz4 $(zfs list | grep $(hostname) | awk '{print $1}')
  fi

  log_info "存储池配置完成"
}

# 配置网络
configure_network() {
  log_info "配置网络..."

  # 获取默认网络接口
  default_interface=$(ip -4 route show default | awk '{print $5}')

  log_info "默认网络接口: $default_interface"

  # 创建桥接网络
  incus network create br0 bridge.external_interfaces=$default_interface bridge.mode=managed

  # 配置NAT
  incus network set br0 ipv4.nat=true
  incus network set br0 ipv6.nat=true

  # 设置默认配置文件使用新网络
  incus profile device add default eth0 network br0

  log_info "网络配置完成"
}

# 配置防火墙
configure_firewall() {
  log_info "配置防火墙..."

  # 安装ufw
  apt install -y ufw

  # 允许SSH
  ufw allow OpenSSH

  # 允许Incus API
  ufw allow 8443/tcp

  # 启用防火墙
  ufw --force enable

  log_info "防火墙配置完成"
}

# 初始化Incus
initialize_incus() {
  log_info "初始化Incus..."

  # 非交互式初始化
  incus init --auto \
    --network-address 0.0.0.0 \
    --network-port 8443 \
    --storage-backend default \
    --vm-support true

  log_info "Incus初始化完成"
}

# 创建示例虚拟机
create_example_vm() {
  read -p "是否创建示例虚拟机? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    return
  fi

  log_info "创建示例虚拟机..."

  # 创建Ubuntu虚拟机
  incus launch images:ubuntu/22.04 ubuntu-vm --vm

  # 配置虚拟机资源
  incus config set ubuntu-vm limits.cpu 2
  incus config set ubuntu-vm limits.memory 4GB

  log_info "示例虚拟机创建完成"
  log_info "可以使用以下命令访问虚拟机:"
  log_info "incus exec ubuntu-vm -- sudo --user ubuntu --login"
}

# 主函数
main() {
  log_info "开始部署Incus KVM生产环境..."

  check_root
  check_system_requirements
  install_dependencies
  install_incus
  configure_system
  configure_storage
  configure_network
  configure_firewall
  initialize_incus
  create_example_vm

  log_info "======================================================================"
  log_info "Incus KVM生产环境部署完成!"
  log_info "管理界面: https://$(hostname -I | awk '{print $1}'):8443"
  log_info "======================================================================"
}

main
