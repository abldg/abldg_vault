# 部署 OpenStack 2024.1

[-]: #

>1. 全部的服务器的两个网口[**都需要**][-]插上网线,否则会影响VM的外网下载
>1. 参考文档: <https://docs.openstack.org/kolla-ansible/2024.1/user/quickstart.html>

多节点部署时,各个服务的角色说明如下:
| 节点名 |     IP地址     |                   角色                    |
| :----: | :------------: | :---------------------------------------: |
| node35 | 192.168.166.35 | 控制节点 + 网络节点 + 存储节点 + 监控节点 |
| node36 | 192.168.166.36 |           控制节点  + 网络节点            |
| node37 | 192.168.166.37 |                 计算节点                  |
| node38 | 192.168.166.38 |                 计算节点                  |
| deploy | 192.168.166.39 |                 部署节点                  |

>**下面所有的操作均是[root][-]用户通过SSH远程到部署(节点)服务器(166.39)中完成的**

## 1. 修改配置 [pip.conf][-] 和 [ansible.cfg][-]
```bash
## 更新 pip.conf 以使用中科大的pip镜像源
mkdir -p /root/.config/pip 2>/dev/null
bash -c 'tee /root/.config/pip/pip.conf <<"EEE"
[global]
timeout = 180
index-url = https://mirrors.ustc.edu.cn/pypi/simple

[install]
trusted-host = mirrors.ustc.edu.cn
EEE'

## 更新 ansible.cfg 优化后续的安装步骤
mkdir -p /etc/ansible 2>/dev/null
bash -c 'tee /etc/ansible/ansible.cfg <<"EEE"
[defaults]
forks=100
pipelining=True
host_key_checking=False
deprecation_warnings=False
EEE'
```

## 2. 创建 PIP 虚拟环境 [/root/ksv2024.1][-] 并更新相关依赖
```bash
##删除旧目录
rm -rf ~/.ansbile 2>/dev/null
##
python3 -m venv /root/ksv2024.1 && source /root/ksv2024.1/bin/activate

## pip 安装依赖[dbus-python,docker,ansible-core]
pip install -U pip dbus-python docker 'ansible-core>=2.15,<2.16.99'
## 从github下载kolla-ansbile-2024.1
pip install git+https://github.com/openstack/kolla-ansible@stable/2024.1
```

## 3. 拷贝目录[/etc/kolla][-],并更新 [passwords.yml][-] 和 [globals.yml][-]
```bash
## 从虚拟环境中的kolla-ansible/etc/kolla_examples中拷贝文件
rm -rf /etc/kolla 2>/dev/null
cp -rf /root/ksv2024.1/share/kolla-ansible/etc_examples/kolla /etc/
chown -R $USER:$USER /etc/kolla

## 更新[keystone_xxx_password]密码为: ljjx#123
pfile=/etc/kolla/passwords.yml
kolla-genpwd && sed -r -i '/^keystone_.*_password:/s@:.*$@: ljjx#123@' $pfile

## 更新[globals.yml]
## 使用虚拟IP 192.168.166.40 作为WEB的访问入口
## 网口 eno1 为控制网络的接口
## 网口 eno2 为虚拟机访问外网的接口
## 具体配置见 附件中的 globals.yml
```

## 4. 生成GPU直通的配置文件 [nova-api.conf][-] 和 [nova-compute.conf][-]
```bash
speclst='{"vendor_id":"10de","product_id":"2206","dev_type":"type-PCI"}'
speclst+=',{"vendor_id":"10de","product_id":"1e04","dev_type":"type-PCI"}'
mkdir -p /etc/kolla/config/nova 2>/dev/null
bash -c 'cat > /etc/kolla/config/nova/nova-api.conf <<"EEE"
[pci]
pci_topology = True
report_in_placement = true
## 若需要修改参照这一行添加
alias = {"vendor_id": "10de", "product_id": "2206", "name": "gpu3080"}
alias = {"vendor_id": "10de", "product_id": "1e04", "name": "gpu2080"}
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

## 6. 拷贝并修改 [multinode][-] 并开始执行部署步骤
```bash

## multinode文件附件中有示例
cfile=/root/ksv2024.1/share/kolla-ansible/ansible/inventory/multinode
cp -rf $cfile /etc/kolla/multinode

##依次执行下面的步骤(执行每一步的前提是failed=0)
kolla-ansible -i /etc/kolla/multinode -vvv bootstrap-servers
kolla-ansible -i /etc/kolla/multinode -vvv prechecks
kolla-ansible -i /etc/kolla/multinode -vvv pull
kolla-ansible -i /etc/kolla/multinode -vvv deploy

## 安装openstack命令
xxxurl=https://releases.openstack.org/constraints/upper/2024.1
pip install python-openstackclient -c $xxxurl

## 生成[ /etc/kolla/admin-openrc.sh ]环境加载文件
kolla-ansible post-deploy
```

```bash
bash -c 'cat >/etc/profile.d/z90-enable-openstack.sh <<"EEE"
ksvenv=/root/ksv2024.1/bin/activate
fadmrc=/etc/kolla/admin-openrc.sh
if [ -e $ksvenv ] && [ -e $fadmrc ]; then
  source $ksvenv
  source $fadmrc
  source <(openstack complete)
  #source <(kolla-ansible complete)
fi
EEE'
```

## 7. 注册 ubuntu-24.04-amd64.img 并添加GPU相关的flavor
```bash
##加载环境
source /root/ksv2024.1/bin/activate
source /etc/kolla/admin-openrc.sh

## 设置资源上限
# 10 instances,60 cores,96GB ram
admin_proj_id=$(openstack project list | awk '/ admin /{print $2}')
openstack quota set --instances 10 $admin_proj_id
openstack quota set --cores 60 $admin_proj_id
openstack quota set --ram 96000 $admin_proj_id

##注册IMG文件
openstack image create \
  --public --disk-format qcow2 --container-format bare \
  --file ubt2404-alwroot-amd64.img ubt2404

##添加RTX3080
gpuid3080='[{"vendor_id":"10de","product_id":"2206"}]'
openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-3080
openstack flavor set --property "pci_passthrough:alias"="gpu3080:1" gpu-3080
openstack flavor set --property 'pci_passthrough:spec='$gpuid3080 gpu-3080

##添加RTX2080Ti
gpuid2080='[{"vendor_id":"10de","product_id":"1e04"}]'
openstack flavor create --vcpus 20 --ram 20480 --disk 100 gpu-2080
openstack flavor set --property "pci_passthrough:alias"="gpu2080:1" gpu-2080
openstack flavor set --property 'pci_passthrough:spec='$gpuid2080 gpu-2080
```
