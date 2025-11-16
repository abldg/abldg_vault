#!/usr/bin/env bash
## coding=utf-8
##==================================----------==================================
## FILE: 99_usages.sh
## MYPG: abldg, https://github.com/abldg
## LSCT: 2025-10-14 12:07:03
## VERS: 1.0.0
##==================================----------==================================
usg.bash.hotkeys() {
  echo '## BASH 常用的快捷键: ##'
  echo && echo 'Ctrl + l  清除屏幕,同clear'
  echo 'Ctrl + a  将光标定位到命令的开头'
  echo 'Ctrl + e  将光标定位到命令的结尾'
  echo 'Ctrl + u  剪切光标之前的内容,在输错命令或密码'
  echo 'Ctrl + k  剪切光标之后的内容'
  echo 'Ctrl + y  粘贴以上两个快捷键所剪切的内容。Alt+y粘贴更早的内容'
  echo 'Ctrl + w  删除光标左边的参数(选项)或内容(实际是以空格为单位向前剪切一个word)'
  echo 'Ctrl + /  撤销,同Ctrl+x u'
  echo 'Ctrl + f  按字符前移(右向),同KEY_RIGHT'
  echo 'Ctrl + b  按字符后移(左向),同KEY_LEFT'
  echo 'Ctrl + d  删除光标处的字符,同Del键。没有命令时表示注销用户'
  echo 'Ctrl + h  删除光标前的字符'
  echo 'Ctrl + r  逆向搜索命令历史,比history好用'
  echo 'Ctrl + g  从历史搜索模式退出,同ESC'
  echo 'Ctrl + p  历史中的上一条命令,同 KEY_UP'
  echo 'Ctrl + n  历史中的下一条命令,同 KEY_DOWN'
  echo 'Alt  + f  按单词前移,标点等特殊字符与空格一样分隔单词(右向),同Ctrl + KEY_RIGHT'
  echo 'Alt  + b  按单词后移(左向),同Ctrl + KEY_LEFT'
  echo 'Alt  + d  从光标处删除至字尾。可以Ctrl+y粘贴回来'
  echo 'Alt  + \  删除当前光标前面所有的空白字符'
  echo 'Alt  + .  同!$,输出上一个命令的最后一个参数(选项or单词)'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.example.interfaces() {
  local vap_nic=$(ip to | awk '/dev wl/{print $NF}' | head -1)
  [ "X$vap_nic" == "X" ] && vap_nic="${HC_AP_NIC-wlp1s0}"

  echo '# re-generate by HCLINK at $(date +'"'%F %T'"')'
  echo "auto lo"
  echo "iface lo inet loopback"

  echo && echo "auto $vap_nic"
  echo "iface $vap_nic inet static"
  echo "address 192.168.1.1"
  echo "netmask 255.255.255.0"

  echo && echo "auto br-lan"
  echo "iface br-lan inet dhcp"
  echo "bridge_ports eth0 eth1 eth2 eth3 eth4"
  echo "bridge_stp off"
  echo "bridge_fd 0"
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.example.dhcpd() {
  local vi3p=100
  [[ "X$1" != "X" && "X${1//[0-9]/}" == "X" ]] && vi3p=$1 && shift
  local vf3p="192.168.$vi3p"
  echo '# re-generate by HCLINK at $(date +'"'%F %T'"')'
  echo && echo "ddns-update-style  none"
  echo "log-facility       local7"
  echo "default-lease-time 600"
  echo "max-lease-time     7200"
  echo "subnet ${vf3p}.0 netmask 255.255.255.0 {"
  echo "  range  ${vf3p}.100 ${vf3p}.200"
  echo "  option domain-name-servers 114.114.114.114"
  echo "  option domain-name-servers 223.5.5.5"
  echo "  option broadcast-address   ${vf3p}.255"
  echo "  option subnet-mask         255.255.255.0"
  echo "  option routers             ${vf3p}.1"
  echo "}"
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.print.Colors() {

  _ce() {
    case $1 in
    "") echo -n '\e[0m' ;;
    *) echo -n "\e[$(echo $@ | sed 's,[ ,+_=],;,g')m" ;;
    esac
  }

  local vforeground= vbackground=
  #输出常用颜色组合表 - vforeground 为前景(foreground), vbackground 为背景(background)
  echo "常用颜色组合表"
  echo -e "$(_ce 5 37 42)说明 : 色块中数字含义 前景色;背景色$(_ce)"
  echo '---------------------------------------------------------'
  for vforeground in {30..37}; do
    echo -n '|'
    for vbackground in {41..47}; do
      echo -en "$(_ce $vforeground $vbackground) $vforeground;$vbackground $(_ce)|"
    done
    echo
    echo '---------------------------------------------------------'
  done

  echo '上面表中数字的含义如下:            有如下可用的特效值:'
  echo '  30 - 黑色前景, 40 - 黑色背景       0  - 重新到缺省, 1  - 粗体'
  echo '  31 - 红色前景, 41 - 红色背景       2  - 一半亮度,   4  - 下划线'
  echo '  32 - 绿色前景, 42 - 绿色背景       5  - 闪烁,       7  - 反向图象'
  echo '  33 - 黄色前景, 43 - 黄色背景       22 - 一般密度'
  echo '  34 - 蓝色前景, 44 - 蓝色背景       24 - 关闭下划线'
  echo '  35 - 紫色前景, 45 - 紫色背景       38 - 添加下划线'
  echo '  36 - 青色前景, 46 - 青色背景       25 - 关闭闪烁'
  echo '  37 - 白色前景, 47 - 白色背景       27 - 关闭反向图象'

  echo && echo '使用方法如下:'
  echo "  设置当前颜色 echo -n '\e[前景色;背景色;特效值m'"
  echo "  结束当前颜色 echo -n '\e[0m'"

  unset -f _ce
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.fileHandling() {

  echo '# [WARN] bash does not handle binary data properly in versions < 4.4'
  echo && echo '###====== Read a file to a string ======###'
  echo 'file_data="$(</path/to/file)"'

  echo && echo '###====== Read a file to an array ======###'
  echo '# BASH < 4'
  echo 'IFS='"$'\n'"' read -d "" -ra file_data <"/path/to/file"'
  echo '# BASH 4+'
  echo 'mapfile -t file_data <"/path/to/file"'

  echo && echo '###======= Create an empty file ========###'
  echo '#shortest'
  echo '>file'
  echo '#longer:'
  echo ': >file'
  echo 'echo -n >file'
  echo 'printf '"''"' >file'

}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.isContainPattern() {
  echo '##=== Check if string contains a sub-string ===##'
  echo && echo '#-- 1. Using a test: --#'
  echo 'if [[ $var == *sub_string* ]]; then'
  echo '  printf '"'%s\n'"' "sub_string is in var."'
  echo 'fi'

  echo && echo '# Inverse (substring not in string).'
  echo 'if [[ $var != *sub_string* ]]; then'
  echo '  printf '"'%s\n'"' "sub_string is not in var."'
  echo 'fi'

  echo && echo '# This works for arrays too!'
  echo 'if [[ ${arr[*]} == *sub_string* ]]; then'
  echo '  printf '"'%s\n'"' "sub_string is in array."'
  echo 'fi'

  echo && echo '#-- 2. Using a case statement: --#'
  echo 'case "$var" in'
  echo '*sub_string*)  : # Do stuff ;;'
  echo '*sub_string2*) : # Do more stuff ;;'
  echo '*) :             # Else ;;'
  echo 'esac'

  echo && echo '##=== Check if string starts with sub-string ===##'
  echo 'if [[ $var == sub_string* ]]; then'
  echo '  printf '"'%s\n'"' "var starts with sub_string."'
  echo 'fi'
  echo && echo '# Inverse (var does not start with sub_string).'
  echo 'if [[ $var != sub_string* ]]; then'
  echo '  printf '"'%s\n'"' "var does not start with sub_string."'
  echo 'fi'

  echo && echo '##=== Check if string ends with sub-string ===##'
  echo 'if [[ $var == *sub_string ]]; then'
  echo '  printf '"'%s\n'"' "var ends with sub_string."'
  echo 'fi'
  echo && echo '# Inverse (var does not end with sub_string).'
  echo 'if [[ $var != *sub_string ]]; then'
  echo '  printf '"'%s\n'"' "var does not end with sub_string."'
  echo 'fi'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.advBashVariables() {
  echo '#== Assign and access a variable using a variable ==#'
  echo && echo '### BASH < 4.3'
  echo 'hello_world="value"'

  echo && echo '# Create the variable name.'
  echo 'var="world"'
  echo 'ref="hello_$var"'

  echo && echo '# Print the value of the variable name stored in '"'hello_$var'."
  echo 'printf '"'%s\n'"' "${!ref}"'
  echo '--> value'

  echo && echo '### BASH 4.3+'
  echo 'hello_world="value"'
  echo 'var="world"'

  echo && echo '# Declare a nameref.'
  echo 'declare -n ref=hello_$var'

  echo && echo 'printf '"'%s\n'"' "$ref"'
  echo '---> value'

  echo && echo '###====== Name a variable based on another variable ======###'
  echo 'var="world"'
  echo 'declare "hello_$var=value"'
  echo 'printf '"'%s\n'"' "$hello_world"'
  echo '---> value'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.loopOverTotalArray() {
  echo '#example'
  echo 'arr=(apples oranges tomatoes)'

  echo && echo '# Just elements.'
  echo 'for element in "${arr[@]}"; do'
  echo '  printf '"'%s\n'"' "$element"'
  echo 'done'

  echo && echo '# Elements and index.'
  echo 'for i in "${!arr[@]}"; do'
  echo '  printf '"'%s\n'"' "${arr[i]}"'
  echo 'done'

  echo && echo '# Alternative method.'
  echo 'for ((i=0;i<${#arr[@]};i++)); do'
  echo '  printf '"'%s\n'"' "${arr[i]}"'
  echo 'done'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.loopOverFileContents() {
  echo 'while read -r line; do'
  echo '  printf '"'%s\n'"' "$line"'
  echo 'done < "file"'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.listFilesAndDirectories() {

  echo && echo '### [WARN] Do not use ls ###'
  echo 'shopt -s globstar'

  echo && echo '# Greedy example.'
  echo 'for file in *; do'
  echo '  printf '"'%s\n'"' "$file"'
  echo 'done'

  echo && echo '# PNG files in dir.'
  echo 'for file in ~/Pictures/*.png; do'
  echo '  printf '"'%s\n'"' "$file"'
  echo 'done'

  echo && echo '# Iterate over directories.'
  echo 'for dir in ~/Downloads/*/; do'
  echo '  printf '"'%s\n'"' "$dir"'
  echo 'done'

  echo && echo '# Brace Expansion.'
  echo 'for file in /path/to/parentdir/{file1,file2,subdir/file3}; do'
  echo '  printf '"'%s\n'"' "$file"'
  echo 'done'

  echo && echo '# Iterate recursively.'
  echo 'shopt -s globstar'
  echo 'for file in ~/Pictures/**/*; do'
  echo '  printf '"'%s\n'"' "$file"'
  echo 'done'

  echo && echo 'shopt -u globstar'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.bash.variableSubst() {
  local vtip_index=1
  _prititle() { echo -e "\n$((vtip_index++)). $*"; }
  _prititle '${parameter} -- 获取 parameter 的值, 等同于 $parameter'
  echo '    但是有时候需要使用 {} 来隔离不属于此变量名称的其他字符'

  _prititle '${parameter:offset[:length]} -- 截取指定长度的子串, offset,length均可是负整数'
  echo '    整体上可以类比 python 或 go 下面的 分片(slice) 的概念.'
  echo '    当 parameter 为数组名时,有两种具体用法:'
  echo '      ${#ArrayName:X:Y} --- 获取数组中包含第X个元素之后的Y个元素(Y省略时到数组尾部)'

  _prititle '${parameter#prefix}  -- 从 parameter 头部开始，尝试匹配 prefix, 并删除第一次匹配'
  echo '    ${parameter##prefix} -- 从 parameter 头部开始，尝试匹配 prefix, 并删除全部'
  echo '    ${parameter%suffix}  -- 从 parameter 尾部开始，尝试匹配 suffix, 并删除第一次匹配'
  echo '    ${parameter%%suffix} -- 从 parameter 尾部开始，尝试匹配 suffix, 并删除全部'

  _prititle '${parameter/pattern/string} -- 进行模式匹配并替换'
  echo '    当string为空(null)时, 可以简写为 ${parameter/pattern}'

  _prititle '${parameter^pattern}  -- 从 parameter 尝试匹配 pattern, 并将第一次匹配转换成大写字母'
  echo '    ${parameter^^pattern} -- 从 parameter 尝试匹配 pattern, 并将每一个匹配转换成大写字母'
  echo '    ${parameter,pattern}  -- 从 parameter 尝试匹配 pattern, 并将第一次匹配转换成小写字母'
  echo '    ${parameter,,pattern} -- 从 parameter 尝试匹配 pattern, 并将每一个匹配转换成小写字母'

  # _prititle '${parameter@operator} -- 变量格式变换'
  # echo '    ${parameter@Q} -- 对变量加上引号, #==> '"'parameter'"
  # echo '    ${parameter@A} -- 将变量重新设置成位置参数, #==> set -- $parameter '

  _prititle '${!ArrayName[@]} -- 获取数组的 key 的列表'
  _prititle '${#parameter} -- 获取变量 paramter 值的长度'
  echo '    当 parameter 为数组名时,有两种具体用法:'
  echo '      ${#ArrayName[@]} --- 获取数组中元素个数, 此时 @ 也可以替换成 *'
  echo '      ${#ArrayName[X]} --- 获取数组某个元素的长度, X为0时可以简写成 ${#ArrayName}'

  _prititle '${parameter:-word} -- 使用默认值, 可省略掉":", parameter 的值维持不变'
  echo '    当 parameter 未定义(unset) 或 为空(null), 上面的结果为 word'

  _prititle '${parameter:=word} -- 设置默认值, 这种情况下面无法使用 位置参数 及 特殊变量'
  echo '    当 parameter 未定义(unset) 或 为空(null), 将word赋值给parameter后取出parameter的值'

  _prititle '${parameter:?word} -- 输出错误'
  echo '    当 parameter 未定义(unset) 或 为空(null), 将word值作为错误信息输出到屏幕(非交互执行时,退出其执行环境)'

  _prititle '${parameter:+word} -- 使用备用值, 且 parameter 的值维持不变'
  echo '    当 parameter 未定义(unset) 或 为空(null), 不使用备用值;否则, 使用备用值'

  unset -f _prititle
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.git.dailyUsage() {

  echo 'Git 常用命令速查'

  echo && echo 'master :默认开发分支'
  echo 'origin :默认远程版本库'
  echo 'HEAD   :当前分支上提交'
  echo 'HEAD^  :HEAD的父提交'

  echo && echo '1. 创建版本库'
  echo 'git clone <URL>                   # 克隆远程版本库'
  echo 'git init                          # 初始化本地版本库'

  echo && echo '2. 修改和提交'
  echo 'git status                        # 查看状态'
  echo 'git diff                          # 查看变更内容'
  echo 'git add .                         # 跟踪所有改动过的文件'
  echo 'git add <FILE>                    # 跟踪指定的文件'
  echo 'git mv <OLD> <NEW>                # 文件改名'
  echo 'git rm <FILE>                     # 删除文件'
  echo 'git rm --cached <FILE>            # 停止跟踪文件但不删除'
  echo 'git commit -m <COMMIT-MESSSAGES>  # 提交所有更新过的文件'
  echo 'git commit --amend                # 修改最后一次提交'

  echo && echo '3. 查看提交历史'
  echo 'git log                           # 查看提交历史'
  echo 'git log -p <FILE>                 # 查看指定文件的提交历史'
  echo 'git blame <FILE>                  # 以列表方式查看指定文件的提交历史'

  echo && echo '4. 撤销'
  echo 'git reset --hard HEAD             # 撤销工作目录中所有未提交文件的修改内容'
  echo 'git checkout HEAD <FILE>          # 撤销指定的未提交文件的修改内容'
  echo 'git revert <COMMIT>               # 撤销指定的提交'

  echo && echo '5. 分支与标签'
  echo 'git branch                        # 显示所有本地分支'
  echo 'git checkout <BRANCH/TAG>         # 切换到指定分支或标签'
  echo 'git branch <NEW-BRANCH>           # 创建新分支'
  echo 'git branch -d <BRANCH>            # 删除本地分支'
  echo 'git tag                           # 显示所有本地标签'
  echo 'git tag <NEW-TAG>                 # 基于最新提交创建标签'
  echo 'git tag -d <TAG>                  # 删除本地标签'

  echo && echo '6. 合并与衍合'
  echo 'git merge <BRANCH>                # 合并指定分支到当前分支'
  echo 'git rebase <BRANCH>               # 衍合指定分支到当前分支'

  echo && echo '7. 远程操作'
  echo 'git remote -v                     # 查看远程版本库信息'
  echo 'git remote show <REMOTE>          # 查看指定远程版本库信息'
  echo 'git remote add <REMOTE> <URL>     # 添加远程版本库'
  echo 'git fetch <REMOTE>                # 从远程版本库获取代码'
  echo 'git pull <REMOTE> <BRANCH>        # 下载代码并快速合并'
  echo 'git push <REMOTE> <BRANCH>        # 上传代码并快速合并'
  echo 'git push <REMOTE> :<BRANCH/TAG>   # 删除远程分支或标签'
  echo 'git push --tags                   # 上传所有标签'
  echo 'git push --set-upstream origin master -f #将本地分支与远程分支联系起来'

}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.git.ignoreRules() {
  echo '# gitignore 的规则如下:'
  echo && echo '  1. 空行或#起始行会被忽略'
  echo && echo '  2. 可以使用通配符(\*,?,[abc],[a-Z0-9])'
  echo && echo '  3. 转义字符 \'
  echo && echo '  4. ! 表示取反(不忽略),写在某条规则的前面'
  echo && echo '  5. 路径分隔符  /'
  echo '    5.1 后面的名称是目录,则该目录以及该目录下的所有文件都会被忽略'
  echo '    5.2 后面的名称是个文件,则该文件不会被忽略'
  echo && echo '  6. .gitignore文件也可以忽略自己,只要把自己的名字写进来即可'
  echo && echo '  7. 一条(行)忽略规则只对某一个目录下的文件及其子目录有效,而对子目录中的文件无效'
  echo && echo '  8. 一条(行)忽略规则也可以只对单个文件有效(忽略单个指定的文件)'
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.bash.parseArgs() {
  echo && echo 'local thisfile=$(realpath ${BASH_SOURCE})' && echo
  echo 'while :; do'
  echo '  case $1 in'
  echo '  -h | --help | help)'
  echo '    echo "Usage: $FUNCNAME [OPTS]" && return'
  echo '    ;;'
  echo '  -v | --version)'
  echo "    awk -F': ' '/^# LTSVERN: /{"
  echo '      a=$NF'
  echo '      getline'
  echo '      printf("Version: %s, LastUpdated: %s\n",a,$NF)'
  echo "    }' "'$thisfile'
  echo '    ;;'
  echo '  "")'
  echo '    : ##check-begin'
  echo '    : ##check-end'
  echo '    break'
  echo '    ;;'
  echo '  *)'
  echo '    : ##others-all'
  echo '    ;;'
  echo '  esac'
  echo '  shift'
  echo 'done' && echo
}
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.awkSpecialUsage() {
  cat <<"EOF"
#==============================================================
输出文件的前n列:
awk '{NF=n}1' /file/to/deal

#==============================================================
假若在多行数据中, 有首列的值是有重复的，提取符合条件的首行和尾行的方法如下:
METHOD1: [[[ AWK数组解法 ]]]

#[1.1] 提取首行数据
  awk '!a[$1]++' taskFile
  awk '++a[$1]==1' taskFile

#[1.2] 提取尾行数据
  awk '{a[$1]=$0}END{for(i=1;i<=asort(a);i++)print a[i]}' taskFile
  awk '!a[$1]++&&i{print i}{i=$0}END{print i}' taskFile

METHOD2: [[[ AWK非数组解法 ]]]：-------------------------------

#[2.1] 提取首行数据
awk '$1!=x{x=$1;print}' taskFile

#[2.2] 提取尾行数据
awk 'NR>1{if($1!=x)print y}{x=$1;y=$0}' taskFile <(echo)

PS: 话说数组的效率那确实在大文件下够慢的，别看非数组的命令比较长点，效率那可是高的。

METHOD3: [[[ sed解法 ]]]: ------------------------------------

#[3.1] 提取首行数据
sed -r ':a;$!N;s/([^ ]+)( +[^\n]+)\n\1.*/\1\2/;ta;P;D' taskFile

#[3.2] 提取尾行数据
sed -r ':a;$!N;s/([^ ]+) +[^\n]+\n\1(.*)/\1\2/;ta;P;D' taskFile
sed -r '$!N;/([^ ]+ ).*\n\1/!P;D' taskFile

EOF
}
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
usg.genLengthNString() {
  local inp=$1
  if [[ "X$inp" == "X" || "X${inp//[0-9]/}" != "X" ]]; then
    echo "[Error] '$inp' is not a postive number !!!" && return
  fi
  tr -cd '1' </dev/urandom | head -c $inp
  echo
}
