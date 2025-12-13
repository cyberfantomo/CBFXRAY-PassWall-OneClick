#!/bin/bash

# Установщик для OpenWrt по SSH / Installer for OpenWrt via SSH
echo -e '\033[1;34m───────────────────────────────────────────\033[0m'
echo -e '\033[1;34m           Это One-Click Установщик          \033[0m'
echo -e '\033[1;38;5;208m    PassWall Xray v1 | Auto‑Installer v2 [11.2025] \033[0m'
echo -e '\033[1;38;5;208m         Официальный сайт: www.cbf.st \033[0m'
echo -e '\033[1;34m       Для Роутеров на базе OpenWRT v22+\033[0m'
echo -e '\033[1;34m───────────────────────────────────────────\033[0m'

# Установка зависимостей / Installing dependencies
# Smart Update for Gl.iNet
curl -O https://codeberg.org/reserv-repo/gl075/raw/branch/main/smt_update2.sh && chmod +x smt_update2.sh && ash smt_update2.sh
opkg install bash
# Скачивание и установка ключа для репозитория PassWall / Downloading and installing the key for the PassWall repo
wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
opkg-key add passwall.pub
# Добавление репозиториев PassWall / Adding PassWall repositories
read release arch << EOF
$(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
for feed in passwall_luci passwall_packages passwall2; do
  echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done
# Установка LuCI-приложения PassWall / Installing the LuCI PassWall application
opkg update
opkg remove dnsmasq-full
opkg install luci-app-passwall
# Установка других необходимых пакетов / Installing other required packages
opkg install ipset ipt2socks iptables iptables-legacy iptables-mod-conntrack-extra iptables-mod-iprange iptables-mod-socket iptables-mod-tproxy kmod-ipt-nat dnsmasq-full
# Установка Xray Core / Installing Xray Core
opkg update
opkg install xray-core

echo -e '\033[1;32mПочти готово, еще несколько секунд...\033[0m'
echo -e '\033[1;32mAlmost done, just a few more seconds...\033[0m'

sleep 15

# Мини‑настройка PassWall после установки / Mini PassWall post-install configuration
uci set passwall.@global[0].tcp_proxy_mode='global'
uci set passwall.@global[0].udp_proxy_mode='global'
uci set passwall.@global_forwarding[0].tcp_no_redir_ports='disable'
uci set passwall.@global_forwarding[0].udp_no_redir_ports='disable'
uci set passwall.@global_forwarding[0].udp_redir_ports='1:65535'
uci set passwall.@global_forwarding[0].tcp_redir_ports='1:65535'
uci set passwall.@global[0].remote_dns='8.8.4.4'
uci set passwall.@global[0].dns_mode='udp'
uci set passwall.@global[0].udp_node='tcp'
uci set passwall.@global[0].remote_dns='8.8.4.4'
uci set passwall.@global[0].chn_list='0'
uci set passwall.@global[0].tcp_proxy_mode='proxy'
uci set passwall.@global[0].udp_proxy_mode='proxy'
uci commit passwall
uci commit system

# Удаление файла SA_0001.sh / Removing file SA_0001.sh
rm -f passwall-v1-autoinstaller-v2.sh

echo -e '\033[1;32mГотово!\033[0m'
echo -e '\033[1;32mDone!\033[0m'

echo -e '\033[1;32mУстановка клиента PassWall Xray v1 | Auto‑Installer v2 by CBF завершена.\033[0m'
echo -e '\033[1;32mPassWall Xray v1 client installation | Auto-Installer v2 by CBF completed.\033[0m'

echo -e '\033[1;32mПерезагрузка роутера будет выполнена автоматически в течении 20 секунд...\033[0m'
echo -e '\033[1;32mThe router will automatically reboot within 20 seconds...\033[0m'

sleep 5

reboot
