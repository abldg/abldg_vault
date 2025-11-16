# Ubuntu24.04切换GPU的驱动为vfio-pci

## 1. 设置[vfio-pci]驱动统管NVIDIA所有设备

```bash
## 获取所有的NVIDIA相关的设备列表
nvlst="$(lspci -nk | awk '/10de:/{print $3}' | sort -u | xargs | sed 's@ @,@g')"

## 更新配置
cfile='/etc/modprobe.d/ljjx-nvidia-devices-use-vfio-pci.conf'
bash -c 'cat > '$cfile' <<"EEE"
##ADD-BY-LJJX

##append-into-blocklist
blacklist amd76x_edac
blacklist i2c_nvidia_gpu
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
blacklist rivafb
blacklist rivatv
blacklist snd_hda_intel
blacklist vga16fb
blacklist xhci_pci

##newadd-vfio
options vfio-pci ids="'$nvlst'"
EEE'
```

## 2. 设置开机自动加载VFIO及KVM的驱动

```bash
## 更新配置
cfile='/etc/modules-load.d/ljjx-autoload-vfio-pci-kvm-drivers.conf'
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

## 3. 更新文件[/etc/default/grub]

```bash
## 添加 iommu=pt
cfile='/etc/default/grub'
newct='intel_iommu=on amd_iommu=on iommu=pt '
newct+='default_hugepagesz=1G hugepagesz=1G hugepages=8'
if ! grep -Eq '^GRUB_CMDLINE_LINUX_DEFAULT=".* iommu=pt' $cfile; then
  sed -r -i '/^GRUB_CMDLINE_LINUX_DEFAULT="/s@="@="'"$newct"'@' $cfile
fi
```

## 4. 重启验证

```bash
## 验证 iommu=pt
grep iommu /proc/cmdline

## 验证 vfio_pci
lspci -nnk -d 10de:
```
