#################################### storage ###################################
#[TIP]. create-storage-via-dir: [ /opt/incusrt ]
incus storage create disks dir source=/opt/incusrt
incus profile device add default root disk path=/ pool=disks size=10GiB

#[TIP]. create-storage-via-zfs-pool-[disks:/dev/sdb]
incus storage create disks zfs source=/dev/sdb
incus profile device add default root disk path=/ pool=disks size=300GiB

################################ certification #################################
#[TIP]. incus-add-certificate
incus config trust add-certificate RV_UICRT

################################ remote-mirror #################################
#[TIP]. change-remote-images-mirror: [https://mirrors.nju.edu.cn/lxc-images]
mirurl=https://mirrors.nju.edu.cn/lxc-images && incus remote remove images
incus remote add images $mirurl --protocol=simplestreams --public

############################### default-profile ################################
#[TIP]. update-profile-of-default
incus profile set default limits.cpu ${sz_cpu:-4}
incus profile set default limits.memory ${sz_mem:-4}GiB
incus profile set default security.guestapi true
incus profile set default security.nesting true
incus profile set default security.privileged true
incus profile set default security.secureboot false

############################## instance-creations ##############################
## with arg [--vm] will run-as-a-vm
#[TIP]. create-and-start-a-ubuntu-24.04-vm
incus launch images:ubuntu/24.04 --vm ubt2404vm

#[TIP]. create-and-start-a-openeuler-24.03-vm
incus create images:openeuler/24.03 --vm oe2403vm
incus config device add oe2403vm agent disk source=agent:config
incus start oe2403vm
