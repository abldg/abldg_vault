## 一、基础环境配置

1. ‌节点规划‌

    - 所有节点需安装Ubuntu 22.04.5，内核版本 ≥ 5.15
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

- ([ALL][0])配置主机名映射, 修改 `/etc/hosts`
  
  ```bash
  ### 删除以 192.168.166. 开头的行
  sudo sed -i -r '/^(##NEWAPD|192\.168\.166.)/d' /etc/hosts
  
  ### 追加映射
  bash -c 'sudo cat >> /etc/hosts <<"EEE"
  ##NEWAPD##
  192.168.166.93 control01
  192.168.166.94 compute01
  192.168.166.95 compute02
  EEE'
  ```

- ([ALL][0])时间同步(控制节点作为NTP服务器)

  ```bash
  S=sudo fcfg=/etc/chrony/chrony.conf
  ## (ALL)安装chrony
  ${S} apt install -y chrony && ${S} systemctl enable --now chronyd

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

<!-- 
1. ([ALL][0])初始化devstack配置文件 `/opt/devstack/local.conf`

    ```bash
    ## 切换到stack用户
    su - stack
    
    ## 创建 pip.conf 配置
    set -- $HOME/.pip https://mirrors.huaweicloud.com/repository
    mkdir -p $1 2>/dev/null
    bash -c 'cat >'$1'/pip.conf <<"EEE"
    [global]
    index = '$2'/pypi
    index-url = '$2'/pypi/simple
    trusted-host = mirrors.huaweicloud.com
    timeout = 120
    EEE'
    ```    

    ```bash
    ## 新增配置文件
    set -- /opt/devstack/local.conf abc123456
    bash -c 'tee '$1' <<"EEE"
    
    [[local|localrc]]
    DATABASE_PASSWORD='$2'
    RABBIT_PASSWORD='$2'
    SERVICE_PASSWORD='$2'
    ADMIN_PASSWORD='$2'
    EEE'
    ```
-->

## 三、网络配置

1. ([ALL][0])启用网卡混杂模式

    - 管理网络：192.168.166.0/24(用于服务通信,eno1)
    - 数据网络：192.168.2.0/24  (用于实例流量,eno2)
    
    ```bash
    ##假设网口名称为 eno1
    ip link set dev eno1 promisc on
    nmcli connection modify eno1 ethernet.cloned-mac-address permanent
    ```

<!--

三、DevStack部署
‌控制节点配置‌
创建local.conf：

```ini

[[local|localrc]]
HOST_IP=10.20.0.10
SERVICE_HOST=$HOST_IP
ENABLED_SERVICES="mysql,rabbitmq,apache,key,n-api,n-crt,n-obj,n-cond,n-sch,placement-api"
LOGDIR=/opt/stack/logs
‌计算节点配置‌

ini

[[local|localrc]]
HOST_IP=10.20.0.11
SERVICE_HOST=10.20.0.10
ENABLED_SERVICES="n-cpu,q-agt"
（需预先配置SSH密钥免密登录控制节点）68

‌执行部署‌

bash

git clone https://opendev.org/openstack/devstack
cd devstack && ./stack.sh
日志实时监控：tail -f /var/log/stack.log

四、验证与排错
‌服务状态检查‌

bash

openstack service list  # 验证核心服务
nova-manage service list  # 查看计算节点注册状态
‌常见问题处理‌

‌依赖冲突‌：手动安装指定版本Python库（如pip install pytz==2023.3）35
‌网络异常‌：检查OVS桥接配置ovs-vsctl show，确认Neutron代理状态openstack network agent list78

-->
