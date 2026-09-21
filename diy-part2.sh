#!/bin/bash
set -e

# diy-part2.sh (v5) - Phicomm K2P 16MB slim + OpenClash
# Must run AFTER feeds update/install and .config is in place.
# Working dir = openwrt source root.
#
# Slim strategy (v3 failed: .config is not set gets reverted by make
# defconfig, so we patch at source level):
#   1) wpad-openssl -> wpad-basic-wolfssl  (save ~0.8MB)
#   2) drop OpenClash +ruby / +ruby-yaml deps (save ~2.5MB, biggest head)
#   3) drop luci pull of oui / package-manager (save ~0.6MB)
#   4) after defconfig, force-off packages restored by SELECT
#
# NOTE: after flashing, in OpenClash Global Settings -> Rule Settings,
# disable "Use Ruby to process rules" (switch to Gawk/Shell), else
# subscription rule conversion fails.

# 1) K2P device: wpad-openssl -> wpad-basic-wolfssl
MK="target/linux/ramips/image/mt7621.mk"
if [ -f "$MK" ]; then
    sed -i 's#DEVICE_PACKAGES := -wpad-openssl -uboot-envtools#DEVICE_PACKAGES := wpad-basic-wolfssl -uboot-envtools#' "$MK"
    echo "[diy] K2P device wpad -> wpad-basic-wolfssl"
else
    echo "[diy] skip wpad ($MK missing)"
fi

# 2) OpenClash: drop +ruby / +ruby-yaml deps
OC=$(find . -path '*luci-app-openclash/Makefile' 2>/dev/null | head -1)
if [ -n "$OC" ]; then
    sed -i -e 's#+ruby-yaml##g' -e 's#+ruby##g' "$OC"
    echo "[diy] OpenClash ruby dep dropped: $OC"
else
    echo "[diy] OpenClash Makefile not found"
fi

# 3) luci: drop oui / package-manager deps
LMK=$(find . -name Makefile -path '*feeds/luci*' 2>/dev/null | grep -E '/luci/Makefile$' | head -1)
if [ -n "$LMK" ]; then
    sed -i -e 's#+luci-app-oui##g' -e 's#+luci-app-package-manager##g' "$LMK"
    echo "[diy] luci oui/pm deps dropped: $LMK"
else
    echo "[diy] feeds/luci/Makefile not found"
fi

# 4) after defconfig, force-off packages restored by SELECT
make defconfig
for p in luci-app-oui luci-app-package-manager luci-proto-ipv6; do
    sed -i "s#^CONFIG_PACKAGE_${p}=y# CONFIG_PACKAGE_${p} is not set#" .config
done
echo "[diy] done"
