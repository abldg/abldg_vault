# CentOS7.x系列 安装显卡驱动

# 1. 查看是否含有英伟达显卡
lspci | grep -i NVIDIA

#下面说明有1块英伟达的显卡
lspci | grep -i NVIDIA
#04:00.0 VGA compatible controller: NVIDIA Corporation GP104GL [Quadro P4000] (rev a1)
#04:00.1 Audio device: NVIDIA Corporation GP104 High Definition Audio Controller (rev a1)

# 2. 添加ELRepo源
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

# 3. 安装ELRepo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

# 4. 安装nvidia-detect
yum install nvidia-detect -y

# 5. 运行nvidia-detect
nvidia-detect -v

# 6. 查找驱动程序
yum search kmod-nvidia

# 7. 安装驱动程序
yum install kmod-nvidia.x86_64 -y

# 8. 查看禁用Nouveau
lsmod | grep nouveau
#若没有输出 则说明禁用成功，否则执行下面的命令

# 9. 在/etc/modprobe.d/blacklist-nouveau.conf中创建一个文件，其内容如下：
cfg1=/etc/modprobe.d/blacklist-nouveau.conf
echo -e 'blacklist nouveau\noptions nouveau modeset=0' >$cfg1

# 10. 重新生成内核initramfs
dracut --force

# 11. 重启系统
reboot

# 12. 测试
nvidia-smi
##> NVIDIA-SMI has failed because it couldn't communicate with the NVIDIA driver.
##> Make sure that the latest NVIDIA driver is installed and running.
