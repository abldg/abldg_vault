##使能计算节点上的[IOMMU] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ptsrh1='GRUB_CMDLINE_LINUX_DEFAULT="'
if ! grep -Eq '^'$ptsrh1'.* iommu=pt' /etc/default/grub; then
  apdct1='intel_iommu=on amd_iommu=on iommu=pt '
  apdct1+='default_hugepagesz=1G hugepagesz=1G hugepages=8'
  sed -r -i '/^'$ptsrh1'/s@="@="'"$apdct1"'@' /etc/default/grub
fi

update-grub2

##设置VFIO-PCI统管NVIDIA所有设备([GPU/AUDIO/TYPEC-USB/xxxx]) ~~~~~~~~~~~~~~~~~~~~
cfile2=/etc/modprobe.d/ljjx-nvidia-devices-use-vfio-pci.conf
nvdevs=$(lspci -nk | awk '/10de:/{print $3}' | sort -u | xargs | sed 's@ @,@g')
{
  echo '##ADD-BY-LJJX'
  echo '##append-into-blocklist'
  echo 'blacklist amd76x_edac'
  echo 'blacklist i2c_nvidia_gpu'
  echo 'blacklist nouveau'
  echo 'blacklist nvidia'
  echo 'blacklist nvidiafb'
  echo 'blacklist rivafb'
  echo 'blacklist rivatv'
  echo 'blacklist snd_hda_intel'
  echo 'blacklist vga16fb'
  echo 'blacklist xhci_pci'
  echo
  echo '##newadd-vfio'
  echo 'options vfio-pci ids='"$nvdevs"
} >$cfile2

##设置开机自动加载VFIO及KVM的驱动 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cfile3=/etc/modules-load.d/ljjx-autoload-vfio-pci-kvm-drivers.conf
{
  echo '##ADD-BY-LJJX'
  echo 'pci_stub'
  echo 'vfio'
  echo 'vfio_iommu_type1'
  echo 'vfio_pci'
  echo 'kvm'
  echo 'kvm_intel'
} >$cfile3

##重启后验证 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
lspci -nnk -d 10de:
