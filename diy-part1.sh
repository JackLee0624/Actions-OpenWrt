#!/bin/bash
#
# 文件: diy-part1.sh
# 说明: 在「更新 feeds 之前」执行的定制脚本
#       适用于 P3TERX/Actions-OpenWrt 模板
#       作用: 追加第三方软件源（OpenClash 官方源）
#

# ==== 追加 OpenClash 官方源码（vernesong/OpenClash）====
# 之后 workflow 里的 ./scripts/feeds update -a / install -a
# 会自动把 luci-app-openclash 拉进来，配合 .config 里的
# CONFIG_PACKAGE_luci-app-openclash=y 即可只编译该插件
echo 'src-git openclash https://github.com/vernesong/OpenClash.git' >> feeds.conf.default

# ==== 可选: 修改默认后台 IP (默认 192.168.1.1) ====
# 取消下一行注释即可改成 192.168.50.1
# sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate
