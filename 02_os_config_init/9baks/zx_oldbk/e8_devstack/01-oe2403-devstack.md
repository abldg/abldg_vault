## 一、基础环境配置

1. ‌节点规划‌

    - 所有节点需安装openEuler 24.03 SP1，内核版本≥6.6
    - 控制节点（controller）：管理核心服务（MySQL/RabbitMQ/Keystone等）
    - 计算节点（compute）：运行nova-compute和网络代理服务

    <br>接下来的安装按照如下拓扑进行：

    | 名称           | 简称/代号       | 实际IP    |
    | :------------- | :---- | :-------- |
    | **controller** |  CTL  | **192.168.166.93** |
    | **compute**    |  CPT  | **192.168.166.94** |
    | **storage**    |  STG  | **192.168.166.95** |

    > 如果您的环境IP不同，请按照您的环境IP修改相应的配置文件。
    
    <br>**说明**: 在`何处节点`执行指定的shell命令
    > - (ALL) : 全部节点上都需要执行
    > - (CTL) : 仅在 控制(controller) 节点执行
    > - (CPT) : 仅在 计算(compute) 节点执行
    > - (STG) : 仅在 存储(storage) 节点执行
    > - (non-CTL) : 在全部的非控制节点执行
    
1. 系统初始化‌
  
- ([ALL][0])关闭防火墙和SELinux
  
  ```bash
  systemctl disable --now firewalld
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

- ([ALL][0])配置主机名映射, 修改 `/etc/hosts`
  
  ```bash
  ### 删除以 192.168.166. 开头的行
  sudo sed -i '/^192\.168\.166./d' /etc/hosts
  
  ### 追加映射
  bash -c 'sudo tee -a /etc/hosts <<"EEE"
  192.168.166.93 dsn-ctl controller
  192.168.166.94 dsn-cpt1 compute1
  192.168.166.95 dsn-cpt2 compute2
  EEE'
  ```

- ([ALL][0])时间同步(控制节点作为NTP服务器)

  ```bash
  S=sudo P=yum fcfg=/etc/chrony.conf
  ## (ALL)安装chrony
  ${S} ${P} install -y chrony && ${S} systemctl enable --now chronyd

  ## (CTL)修改配置,允许 192.168.X.X 同步
  ${S} sed -i '/^#allow/s@^#@@' ${fcfg}
  
  ## (non-CTL)修改配置
  ### 注掉一行,表示不从公网同步时钟
  ${S} sed -i '/^pool pool.ntp.org /s@^@#@' ${fcfg}
  ### 新增一行,表示从 controller 这个机器获取时间
  echo 'server controller iburst'| ${S} tee -a ${fcfg}
  ### 验证配置
  ${S} systemctl restart chronyd && chronyc sources
  ```

- ([ALL][0])更新`YUM`源配置

  > [mbk/oe_yum.tgz][1]

  ```bash
  set -- mbk/*yum*.tgz
  tar -zcvf $1 -C /
  ```

- ([ALL][0])安装依赖

  ```bash
  pkgs=(git python3-devel libffi-devel openssl-devel gcc make)
  pkgs+=(iptables tar wget python3-devel httpd-devel memcached)
  pkgs+=(iscsi-initiator-utils libvirt python3-libvirt qemu dstat)
  yum install -y ${pkgs[@]}
  ```
[1]: mbk/oe_yum.tgz

## 二、DevStack部署

[0]: #blank

1. ([ALL][0])下载devstack最新的稳定分支代码,并配置环境

    ```bash
    dsdir=/opt/stack/wksp/devstack
    ## 下载最新的稳定分支代码
    set -- stable/2025.1 https://opendev.org/openstack/devstack.git
    git clone --depth=1 -b $1 $2 ${dsdir}
    
    ## 创建stack用户
    ${dsdir}/tools/create-stack-user.sh
    ## 修改目录权限
    chown -R stack:stack ${dsdir}
    chmod -R 755 /opt/stack
    ```

## 三、网络配置

1. ([ALL][0])启用网卡混杂模式

    - 管理网络：192.168.166.0/24(用于服务通信,eno1)
    - 数据网络：192.168.2.0/24  (用于实例流量,eno2)
    
    ```bash
    ##假设网口名称为 eno1
    ip link set dev eno1 promisc on
    nmcli connection modify eno1 ethernet.cloned-mac-address permanent
    ```
