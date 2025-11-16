##适用在[Ubuntu 22.04]上基于kolla-ansible部署 openstack-2024.1
##参考文档: https://docs.openstack.org/kolla-ansible/2024.1/user/quickstart.html

###四台机器(166.30/166.31/166.32/166.33)角色说明
## (all) 代表全部的节点

#(all)# 创建配置文件[$HOME/.config/pip/pip.conf]
mkdir -p $HOME/.config/pip
bash -c 'cat > '$HOME'/.config/pip/pip.conf <<"EEE"
[global]
timeout = 60
index-url = https://mirrors.ustc.edu.cn/pypi/simple

[install]
trusted-host = mirrors.ustc.edu.cn
EEE'

#(all)# 初始化[/etc/netplan/00_loclan.yaml] 注意修改[166.30]
rm -f /etc/netplan/*.yaml
bash -c 'cat > /etc/netplan/00_loclan.yaml <<"EEE"
network:
  version: 2
  ethernets:
    eno2: { dhcp4: no, link-local: [] }
    eno1:
      dhcp4: no
      dhcp6: no
      addresses:
      - 192.168.166.30/24
      routes:
      - { metric: 100, to: 0.0.0.0/0, via: 192.168.166.1 }
      nameservers:
        addresses: [ 223.5.5.5, 114.114.114.114, 8.8.8.8 ]
EEE'

#(all)# 修复ubuntu22.04上[netplan apply]告警错误
fle=/usr/share/netplan/netplan/cli/commands/apply.py
if [ X2 = X$(command grep -c '=jammy' /etc/os-release) ] && [ -e $fle ]; then
  sed -r -i '/^\s+except OvsDbServerNotRunning as e:$/,${d}' $fle
  {
    echo "        except OvsDbServerNotRunning as e:"
    echo "            if utils.systemctl_is_active('ovsdb-server.service'):"
    echo "                logging.warning('Cannot call Open vSwitch: {}.'.format(e))"
  } 2>/dev/null | tee -a $fle
fi

#(all)# 设置四台服务器的hosts映射,并禁用127.0.1.1
sed -r -i -e '/^127.0.1.1 /s@^@#@;/^#LJJX_BGN#/,/^#LJJX_END#/{d}' /etc/hosts
{
  echo '#LJJX_BGN#'
  echo '192.168.166.30 deploy    svr-166-30'
  echo '192.168.166.31 control01 svr-166-31'
  echo '192.168.166.32 control02 svr-166-32'
  echo '192.168.166.33 control03 svr-166-33'
  echo '#LJJX_END#'
} >>/etc/hosts

#(all)# 安装依赖(apt)
pkglst='git gcc libffi-dev libssl-dev libdbus-glib-1-dev '
pkglst+='python3-dev python3-venv python3-pip '
apt update -y && apt upgrade -y && apt install -y $pkglst

#(storage0X)# 对硬盘[/dev/sdb]创建vg[cinder-volumes]
diskpath=/dev/sdb && wipefs --all --force $diskpath
pvcreate $diskpath && vgcreate cinder-volumes $diskpath

#(deploy)# 创建配置文件[/etc/ansible/ansible.cfg]
mkdir -p /etc/ansible
bash -c 'cat >/etc/ansible/ansible.cfg <<"EEE"
[defaults]
forks=100
pipelining=True
host_key_checking=False
deprecation_warnings=False
EEE'

#(deploy)# 设置deploy对其他所有角色的ssh免密登录
for x in deploy control01 control02 control03 svr-166-3{0,1,2,3}; do
  ssh-copy-id -f -o StrictHostKeyChecking=no root@$x
done
#(deploy)# 创建虚拟环境
vdir=/root/kolla_venv2024.1
python3 -m venv $vdir && source $vdir/bin/activate
#(deploy)# pip下载安装stable/xxx及其依赖
pip install -U pip dbus-python docker 'ansible-core>=2.15,<2.16.99'
pip install git+https://github.com/openstack/kolla-ansible@stable/2024.1
#(deploy)# 拷贝globals.yml及password.yml
rm -rf /etc/kolla
cp -rf $vdir/share/kolla-ansible/etc_examples/kolla /etc
chown -R $USER:$USER /etc/kolla
#(deploy)# 修改keystone_xxxx_password:内容
kolla-genpwd
sed -r -i '/^keystone_.*_password:/s@:.*$@: ljjx#123@' /etc/kolla/passwords.yml

#(deploy)# 生成 [ /etc/kolla/config/nova/nova-{api,compute}.conf] 配置GPU直通
mkdir -p /etc/kolla/config/nova
bash -c 'cat > /etc/kolla/config/nova/nova-api.conf <<"EEE"
[pci]
pci_topology = True

#[pci]
report_in_placement = true
alias = {"vendor_id": "10de", "product_id": "2206", "name": "gpu-rtx3080"}
alias = {"vendor_id": "10de", "product_id": "1e04", "name": "gpu-rtx2080ti"}
device_spec = [{"vendor_id":"10de","product_id":"2206","dev_type":"type-PCI"},{"vendor_id":"10de","product_id":"1e04","dev_type":"type-PCI"}]
EEE'
cp -f /etc/kolla/config/nova/nova-{api,compute}.conf

#(deploy)# 更新globals.yml
bash -c 'cat >>/etc/kolla/globals.yml<<"EEE"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
enable_nova: "yes"
enable_neutron: "yes"
enable_glance: "yes"
enable_horizon: "yes"
enable_placement: "yes"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#enable_cinder: "yes"
#enable_cinder_backend_lvm: "yes"
#cinder_volume_group: "cinder-volumes"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
openstack_release: "2024.1"
kolla_base_distro: "ubuntu"
kolla_install_type: "binary"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##docker-settings-for-CN
docker_namespace: "kolla"
docker_apt_url: "https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu"
docker_registry: "vgnxamtipjkx4a.xuanyuan.run"
docker_registry_mirrors: [ "https://vgnxamtipjkx4a.xuanyuan.run" ]
###PCI-passthrough~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nova_enable_pci_passthrough: "yes"
nova_compute_virt_type: "kvm"
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##NetworkSettings
# 网络接口配置
network_interface: "eno1"  # 替换为实际管理网络接口
#api_interface: "{{ network_interface }}"
#storage_interface: "{{ network_interface }}"
#cluster_interface: "{{ network_interface }}"
#tunnel_interface: "{{ network_interface }}"
#dns_interface: "{{ network_interface }}"

# VIP配置
enable_haproxy: "yes"
kolla_internal_vip_address: "192.168.166.40"
kolla_external_vip_address: "{{ kolla_internal_vip_address }}"
kolla_external_vip_interface: "{{ network_interface }}"

# Neutron配置
neutron_plugin_agent: "openvswitch"
#enable_neutron_dvr: "yes"           # 启用分布式路由（多计算节点必需）
#neutron_type_drivers: "flat,vxlan,vlan"
#neutron_tenant_network_types: "vxlan"
#neutron_mechanism_drivers: "openvswitch"

# 外部网络(VM通外网的关键)
enable_neutron_provider_networks: "yes"
neutron_external_interface: "eno2"  # 外部网络物理接口(0连接物理交换机)
neutron_bridge_name: "br-ex"        # OVS 外部网桥名称
bridge_interface_mappings: "physnet1:br-ex"
enable_neutron_dvr: "yes"  # 分布式虚拟路由，提高网络性能
enable_neutron_lbaas: "yes"
enable_neutron_fwaas: "yes"
enable_neutron_vpnaas: "yes"

# 安全组配置
neutron_security_groups: "yes"
neutron_security_group_default_rule: "yes"

# 其他网络优化配置
neutron_max_retries: 3
neutron_retry_interval: 10

EEE'
#(deploy)# 更新password.yml 并
rm -rf $HOME/.ansbile 2>/dev/null
kolla-ansible install-deps -vvvv
#大概率报超时错误
#ansible-galaxy collection install --force \
#  -r $vdir/share/kolla-ansible/requirements-core.yml
#(deploy)# 修改 download.docker.com 相关的URL
(
  cd $HOME/.ansible/collections/ansible_collections/
  sed -i 's@download.docker.com@mirrors.ustc.edu.cn/docker-ce@g' \
    openstack/kolla/roles/docker/defaults/main.yml \
    community/docker/tests/integration/targets/setup_docker/tasks/[FDR]*.yml
)

#(deploy)# 更新 multinode
## svr-166-30 角色为 [ deploy, storage01, monitor01, network01 ]
## svr-166-31 角色为 [ control01, compute01 ]
## svr-166-32 角色为 [ control02, compute02 ]
## svr-166-33 角色为 [ control03, compute03 ]
cp -rf $vdir/share/kolla-ansible/ansible/inventory/multinode multinode

#(deploy)#
kolla-ansible -i multinode -vvv bootstrap-servers
kolla-ansible -i multinode -vvv prechecks
kolla-ansible -i multinode -vvv pull
kolla-ansible -i multinode -vvv deploy
pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/2024.1
kolla-ansible post-deploy

##
openstack image create --disk-format qcow2 --container-format bare --public --file ubt2404-alwroot-amd64.img ubt2404

openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-3080
##添加RTX3080
openstack flavor set --property "pci_passthrough:alias"="gpu-rtx3080:1" gpu-3080
openstack flavor set --property 'pci_passthrough:spec=[{"vendor_id":"10de","product_id":"2206"}]' gpu-3080

##添加RTX2080Ti
openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-2080ti
openstack flavor set --property "pci_passthrough:alias"="gpu-rtx2080ti:1" gpu-2080ti
openstack flavor set --property 'pci_passthrough:spec=[{"vendor_id":"10de","product_id":"1e04"}]' gpu-2080ti
