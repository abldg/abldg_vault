# 部署OpenStack(All-In-One)

[-]: #

> - 需要 [root][-] 用户通过SSH远程到服务器中完成所有操作
> - 服务器的两个网口[**都需要**][-]插上网线,否则会影响VM的外网下载
> - 参考文档: <https://docs.openstack.org/kolla-ansible/2024.1/user/quickstart.html>

## 1. 修改配置 [pip.conf][-] 和 [ansible.cfg][-]
```bash
## 更新 pip.conf 以使用中科大的pip镜像源
mkdir -p /root/.config/pip 2>/dev/null
bash -c 'cat > /root/.config/pip/pip.conf <<"EEE"
[global]
timeout = 180
index-url = https://mirrors.ustc.edu.cn/pypi/simple

[install]
trusted-host = mirrors.ustc.edu.cn
EEE'

## 更新 ansible.cfg 优化后续的安装步骤
mkdir -p /etc/ansible 2>/dev/null
bash -c 'cat > /etc/ansible/ansible.cfg <<"EEE"
[defaults]
forks=100
pipelining=True
host_key_checking=False
deprecation_warnings=False
EEE'
```

## 2. 创建 PIP 虚拟环境 [/root/kavenv][-] 并更新相关依赖
```bash
##删除旧目录
rm -rf ~/.ansbile 2>/dev/null
##
python3 -m venv /root/kavenv && source /root/kavenv/bin/activate

## pip 安装依赖[dbus-python,docker,ansible-core]
pip install -U pip dbus-python docker 'ansible-core>=2.15,<2.16.99'

## 从github下载kolla-ansbile-2024.1
pip install git+https://github.com/openstack/kolla-ansible@stable/2024.1
```

## 3. 拷贝目录[/etc/kolla][-],并更新 [passwords.yml][-] 和 [globals.yml][-]
```bash
## 从虚拟环境中的kolla-ansible/etc/kolla_examples中拷贝文件
rm -rf /etc/kolla 2>/dev/null
cp -rf /root/kavenv/share/kolla-ansible/etc_examples/kolla /etc/
chown -R $USER:$USER /etc/kolla

## 更新[keystone_xxx_password]密码为: ljjx#123
pfile=/etc/kolla/passwords.yml
kolla-genpwd && sed -r -i '/^keystone_.*_password:/s@:.*$@: ljjx#123@' $pfile

## 更新[globals.yml]
ifns=($(ip link | awk -F': ' '$2~/^e[ntm].*/{print $2}'))
ifn1_ip=$(ip -4 -j r get 1 | jq -r '.[0].prefsrc')
bash -c 'cat >> /etc/kolla/globals.yml <<"EEE"
##ADD-BY-LJJX~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker_namespace: "kolla"
docker_apt_url: "https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu"
docker_registry: "rtf0h2092ed1um.xuanyuan.run"
docker_registry_insecure: "yes"
docker_registry_mirrors: [ "https://rtf0h2092ed1um.xuanyuan.run" ]

kolla_base_distro: "ubuntu"
kolla_install_type: "binary"
openstack_release: "2024.1"    # 根据版本调整

kolla_internal_vip_address: "'$ifn1_ip'"
neutron_external_interface: "'${ifns[1]}'"
network_interface: "'${ifns[0]}'" # 注意需要替换为实际网卡名    
enable_cinder: "no"               # 单节点模式及仅有单个控制节点的场景下需要禁用
enable_haproxy: "no"              # 单节点模式及仅有单个控制节点的场景下需要禁用
#nova_compute_virt_type: "kvm"
enable_keepalived: "no"
# 启用 PCI 直通
nova_enable_pci_passthrough: "yes"
enable_nova: "yes"
enable_neutron: "yes"
enable_glance: "yes"
#enable_cinder: "yes"
enable_horizon: "yes"
enable_placement: "yes"
EEE'
```

## 4. 生成GPU直通的配置文件[ nova-api.conf 及 nova-compute.conf ][-]
```bash
speclst='{"vendor_id":"10de","product_id":"2206","dev_type":"type-PCI"}'
speclst+=',{"vendor_id":"10de","product_id":"1e04","dev_type":"type-PCI"}'
mkdir -p /etc/kolla/config/nova 2>/dev/null
bash -c 'cat > /etc/kolla/config/nova/nova-api.conf <<"EEE"
[pci]
pci_topology = True
report_in_placement = true
alias = {"vendor_id": "10de", "product_id": "2206", "name": "gpu-rtx3080"}
alias = {"vendor_id": "10de", "product_id": "1e04", "name": "gpu-rtx2080ti"}
device_spec = ['"${speclst}"']
EEE'
cp -f /etc/kolla/config/nova/nova-{api,compute}.conf
```

## 5. 安装 Galaxy 依赖, 并修复download.docker.com相关的URL
```bash
## 安装glaxy依赖
kolla-ansible install-deps -vv

## 更新URL
bdir=~/.ansible/collections/ansible_collections
sed -i 's@download.docker.com@mirrors.ustc.edu.cn/docker-ce@g' \
$bdir/openstack/kolla/roles/docker/defaults/main.yml \
$bdir/community/docker/tests/integration/targets/setup_docker/tasks/[FDR]*.yml
```

## 6. 拷贝 [all-in-one][-] 并开始执行部署步骤
```bash
cp -rf /root/kavenv/share/kolla-ansible/ansible/inventory/all-in-one aio

##依次执行下面的步骤(执行每一步的前提是failed=0)
kolla-ansible -i aio -vvv bootstrap-servers
kolla-ansible -i aio -vvv prechecks
kolla-ansible -i aio -vvv pull
kolla-ansible -i aio -vvv deploy

## 安装openstack命令
pip install python-openstackclient \
  -c https://releases.openstack.org/constraints/upper/2024.1

## 生成[ /etc/kolla/admin-openstack.sh ]环境加载文件
kolla-ansible post-deploy
```

## 7. 注册 ubuntu-24.04-amd64.img 并添加GPU相关的flavor
```bash
##加载环境
source /root/kavenv/bin/activate
source /etc/kolla/admin-openrc.sh

openstack image create \
  --disk-format qcow2 \
  --container-format bare \
  --file ubt2404-alwroot-amd64.img \
  --public ubt2404

openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-3080
##添加RTX3080
openstack flavor set --property \
  "pci_passthrough:alias"="gpu-rtx3080:1" gpu-3080
openstack flavor set --property \
  'pci_passthrough:spec=[{"vendor_id":"10de","product_id":"2206"}]' gpu-3080

##添加RTX2080Ti
openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-2080ti
openstack flavor set --property \
  "pci_passthrough:alias"="gpu-rtx2080ti:1" gpu-2080ti
openstack flavor set --property \
  'pci_passthrough:spec=[{"vendor_id":"10de","product_id":"1e04"}]' gpu-2080ti
```
