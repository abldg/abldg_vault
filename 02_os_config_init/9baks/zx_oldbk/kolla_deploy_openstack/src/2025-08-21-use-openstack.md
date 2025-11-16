# 使用Openstack

```bash
##加载环境
source /root/ksv2024.1/bin/activate
source /etc/kolla/admin-openrc.sh

##注册IMG文件
openstack image create --public --disk-format qcow2 --container-format bare --file ubt2404-alwroot-amd64.img ubt2404
## 设置VM规格
# 10 instances,150 cores,192GB ram
admin_proj_id=$(openstack project list | awk '/ admin /{print $2}')
openstack quota set --force --instances 10 $admin_proj_id
openstack quota set --force --cores 150 $admin_proj_id
openstack quota set --force --ram 192000 $admin_proj_id

##普通的规格
openstack flavor create --id 1 --ram 512 --disk 1 --vcpus 1 m1.tiny
openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge
openstack flavor create --id 6 --ram 512 --disk 1 --vcpus 2 m2.tiny

## 添加RTX3080的数目不同的规格
gpuid2080='[{"vendor_id":"10de","product_id":"1e04"}]'
gpuid3080='[{"vendor_id":"10de","product_id":"2206"}]'
## [cpu:20c, mem:20g, disk: 50g, gpu:1]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-3080-1
openstack flavor set --property "pci_passthrough:alias=gpu3080:1" gpu-3080-1
openstack flavor set --property "pci_passthrough:spec=$gpuid3080" gpu-3080-1
## [cpu:20c, mem:20g, disk: 50g, gpu:2]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-3080-2
openstack flavor set --property "pci_passthrough:alias=gpu3080:2" gpu-3080-2
openstack flavor set --property "pci_passthrough:spec=$gpuid3080" gpu-3080-2
## [cpu:20c, mem:20g, disk: 50g, gpu:3]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-3080-3
openstack flavor set --property "pci_passthrough:alias=gpu3080:3" gpu-3080-3
openstack flavor set --property "pci_passthrough:spec=$gpuid3080" gpu-3080-3
## [cpu:20c, mem:20g, disk: 50g, gpu:4]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-3080-4
openstack flavor set --property "pci_passthrough:alias=gpu3080:4" gpu-3080-4
openstack flavor set --property "pci_passthrough:spec=$gpuid3080" gpu-3080-4

## 添加RTX2080Ti的数目不同的规格
## [cpu:20c, mem:20g, disk: 50g, gpu:1]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-2080-1
openstack flavor set --property "pci_passthrough:alias=gpu2080:1" gpu-2080-1
openstack flavor set --property "pci_passthrough:spec=$gpuid2080" gpu-2080-1
## [cpu:20c, mem:20g, disk: 50g, gpu:2]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-2080-2
openstack flavor set --property "pci_passthrough:alias=gpu2080:2" gpu-2080-2
openstack flavor set --property "pci_passthrough:spec=$gpuid2080" gpu-2080-2
## [cpu:20c, mem:20g, disk: 50g, gpu:3]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-2080-3
openstack flavor set --property "pci_passthrough:alias=gpu2080:3" gpu-2080-3
openstack flavor set --property "pci_passthrough:spec=$gpuid2080" gpu-2080-3
## [cpu:20c, mem:20g, disk: 50g, gpu:4]
openstack flavor create --vcpus 20 --ram 20480 --disk 50 gpu-2080-4
openstack flavor set --property "pci_passthrough:alias=gpu2080:4" gpu-2080-4
openstack flavor set --property "pci_passthrough:spec=$gpuid2080" gpu-2080-4
```
