<!-- references -->
[1]: #va
[2]: LICENSE
[3]: .env
[4]: doc/startup_cn.png

# 项目介绍

<div align="left">
  <!-- <a href="https://linux-clash.github.io">Website</a> • -->
  <!-- <a href="./README.md">English • </a> -->
  <a href="#"> 若喜欢本项目,请点个小星星! </a>
</div>
<br>

此项目是通过使用开源项目[ ClashPermium ][1]作为核心程序,再结合脚本实现简单的代理功能.<br>
主要是为了解决我们在【[服务器][1]】上下载GitHub等一些国外资源速度慢的问题.

<br>

# 免责声明

1. 本项目使用GNU通用公共许可证 v3.0进行许可.您可以查看[LICENSE][2]文件进行了解<br>

2. 本项目的原作者保留所有知识产权.作为使用者,您需遵守`GPLv 3.0`的要求,
<br>并承担因使用本项目而产生的任何风险.

3. 本项目所提供的内容不提供任何明示或暗示的保证.在法律允许的范围内,<br>
原作者概不负责,不论是直接的、间接的、特殊的、偶然的或后果性的损害.

4. 本项目与仓库的创建者和维护者完全无关,仅作为备份仓库,任何因使用本项目
<br>而引起的纠纷、争议或损失,与仓库的作者和维护者完全无关.

5. 对于使用本项目所导致的任何纠纷或争议,使用者必须遵守自己国家的法律法规,
<br>并且需自行解决因使用本项目而产生的任何法律法规问题.

# 使用须知

- 运行本项目建议使用[root][1]用户,或者使用[sudo][1]提权.
- 此项目[不提供][1]任何订阅信息,请自行准备[Clash订阅地址][1].
- 运行前请手动更改[ .env ][3]文件中的[C4L_LNKURL][1]变量值,否则无法正常运行.
- 当前在RHEL系列和Debian,Ubuntu系统中测试过,其他系列可能需要适当修改脚本.
- [注意][1] :
  - 部分带有桌面端Linux系统的需要在浏览器设置代理!否则有可能无法使用!
  - 若系统代理无法使用,但是想要系统代理,请修改尝试修改中的端口后执行环境变量命令!
  - 还是无法使用请更换当前网络环境(也是其中一个因素!)
- [延伸][1] :
  - 可访问 <https://clash.wiki> 查看与Clash相关的资料
  - 仓库里面自带`x86_64`/`aarch64`平台的[bin/c4l][1]
    - 可通过 <https://downloads.clash.wiki/ClashPremium> 下载其他平台版本

<br>

# 使用教程

## 安装依赖

```bash
## Debian/Ubuntu
apt update -y && apt install -y git curl make

## RHEL/OpenEuler/CentOS
yum update -y && yum install -y git curl make
```

## 下载项目

代码下载从 github 和 gitee 两个的仓库地址当中自行选择一个下载即可
```bash
## github
git clone https://github.com/abldg/linux-clash.git
## gitee
git clone https://gitee.com/abldg/linux-clash.git
```

## 更新订阅链接及页面访问密码

变量在文件中[ .env ][3]保存

```bash
##进入到项目目录
cd linux-clash

##更新订阅链接<必选>
##页面访问密码[可选]
make uptenv <LNKURL=订阅链接> [SECRET=页面访问密码]
```

## 启动程序
>默认` 后台运行 `
- 进入项目目录
```bash
$cd linux-clash && make proxy_enable
```

- 输出如下

![][4]

- 检查进程
```bash
##check pid
ps -ef | grep bin/c4l
```

- 检查服务端口
```bash
$ netstat -tln | grep -E '9090|789.'
tcp        0      0 127.0.0.1:9090          0.0.0.0:*               LISTEN     
tcp6       0      0 :::7890                 :::*                    LISTEN     
tcp6       0      0 :::7891                 :::*                    LISTEN     
tcp6       0      0 :::7892                 :::*                    LISTEN
```

- 检查环境变量
```bash
$ env | grep -iE '_proxy'
http_proxy=http://127.0.0.1:7890
https_proxy=http://127.0.0.1:7890
```

以上步骤如果正常,说明服务clash程序启动成功,现在就可以体验高速下载github资源了.

- 加载工具函数 `proxy_enable` 和 `proxy_disable`

```bash
$ source /etc/profile.d/z99_linux_clash.sh

##使能作用于当前shell的环境变量
$ proxy_enable
```

<br>

## 停止程序

```bash
##停止服务
cd linux-clash && make proxy_disable
```

服务关闭成功,请执行以下命令关闭系统代理：proxy_disable

```bash
$ proxy_disable
```

然后检查程序端口、进程以及环境变量`http_proxy|https_proxy`,若都没则说明服务正常关闭.
<br>

## Clash Dashboard

- 访问 Clash Dashboard

通过浏览器访问启动时后输出的地址,例如：<http://192.168.0.1:9090/ui>

- 登录管理界面

在` API Base URL `一栏中输入：`http://<IP>:9090`, 在`Secret(optional)`一栏中输入`Secret`.

点击Add并选择刚刚输入的管理界面地址,之后便可在浏览器上进行一些配置.

- 更多教程

此 Clash Dashboard 使用的是 <https://github.com/haishanh/yacd> 项目,
详细使用方法请移步到yacd上查询.
<br>
