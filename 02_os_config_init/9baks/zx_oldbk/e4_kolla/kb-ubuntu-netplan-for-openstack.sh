#(all)# 初始化[/etc/netplan/00_loclan.yaml]
rm -f /etc/netplan/*.yaml
bash -c 'cat > /etc/netplan/00_loclan.yaml <<"EEE"
network:
  version: 2
  ethernets:
    eno2: { dhcp4: no, link-local: [] }
    eno1:
      dhcp4: no
      dhcp6: no
      addresses:
      - 192.168.166.30/24
      routes:
      - { metric: 100, to: 0.0.0.0/0, via: 192.168.166.1 }
      nameservers:
        addresses: [ 223.5.5.5, 114.114.114.114, 8.8.8.8 ]
EEE'

#(all)# 修复ubuntu22.04上[netplan apply]告警错误
fle=/usr/share/netplan/netplan/cli/commands/apply.py
if [ X2 = X$(command grep -c '=jammy' /etc/os-release) ] && [ -e $fle ]; then
  sed -r -i '/^\s+except OvsDbServerNotRunning as e:$/,${d}' $fle
  {
    echo "        except OvsDbServerNotRunning as e:"
    echo "            if utils.systemctl_is_active('ovsdb-server.service'):"
    echo "                logging.warning('Cannot call Open vSwitch: {}.'.format(e))"
  } 2>/dev/null | tee -a $fle
fi
