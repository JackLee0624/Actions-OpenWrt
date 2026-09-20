#!/bin/bash
# ==========================================================
# diy-part2.sh
# 执行时机：feeds 已经 update/install 完成、.config 已经就位之后
#           工作目录 = openwrt 源码根目录
#
# 作用：修掉 LEDE 里 K2P 设备定义的一个坑 ——
#   target/linux/ramips/image/mt7621.mk 里写的是：
#     DEVICE_PACKAGES := -wpad-openssl -uboot-envtools kmod-mt7615d_dbdc wireless-tools luci-newapi
#   这个 "-wpad-openssl" 会把 mt7621 默认带的 wpad（WPA 加密/热点）从镜像里摘掉，
#   结果就是刷完 WiFi 起不来、加不了密码。
#   这里把这个负号去掉，让 wpad-openssl 正常进镜像（体积约 1MB）。
# ==========================================================

set -e

MK="target/linux/ramips/image/mt7621.mk"

if [ -f "$MK" ]; then
    sed -i 's/DEVICE_PACKAGES := -wpad-openssl -uboot-envtools/DEVICE_PACKAGES := wpad-openssl -uboot-envtools/' "$MK"
    echo ">>> [diy-part2] K2P 设备定义已打补丁（恢复 wpad-openssl）"
    echo ">>> 当前 K2P 设备块："
    grep -n "phicomm_k2p" -A 7 "$MK" | head -20
else
    echo ">>> [diy-part2] 没找到 $MK，跳过"
fi

echo ">>> [diy-part2] 完成"
