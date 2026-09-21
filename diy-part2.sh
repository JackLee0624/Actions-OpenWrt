#!/bin/bash
# ==========================================================
# diy-part2.sh (v4) 鈥?鏂愯 K2P 16MB 鏋佺畝 + OpenClash
#
# 鎵ц鏃舵満锛歠eeds 宸?update/install銆?config 宸插氨浣嶄箣鍚?#           宸ヤ綔鐩綍 = openwrt 婧愮爜鏍圭洰褰?#
# 鍏抽敭鐦﹁韩锛坴3 澶辫触鏁欒锛氬厜鍦?.config 鍐?is not set 浼氳 make defconfig 澶嶅師锛?#           蹇呴』鍦ㄣ€屾簮鐮佸眰銆嶅姩鎵嬶級锛?#   1) wpad-openssl -> wpad-basic-wolfssl
#      wpad-openssl 鍚畬鏁?hostapd+OpenSSL锛岀害 1MB锛涙崲鎴?wpad-basic-wolfssl
#      锛圵PA2/WPA3-SAE 鍩虹鏀寔锛屽搴鐢級鐪?~0.8MB
#   2) 绉婚櫎 OpenClash 鐨?+ruby / +ruby-yaml 纭緷璧栵紙鐪?~2.5MB锛屾渶澶уご锛?#      鈥斺€?杩欐槸 K2P 16MB 璺?OpenClash 鐨勬爣鍑嗗仛娉曘€?#         鍒锋満鍚庡繀椤诲湪 OpenClash銆屽叏灞€璁剧疆 鈫?瑙勫垯璁剧疆銆嶅叧鎺夆€滀娇鐢?Ruby 澶勭悊瑙勫垯鈥?#         锛堟敼鍕?Gawk/Shell锛夛紝鍚﹀垯璁㈤槄瑙勫垯杞崲浼氬け璐ャ€?#   3) 鍘绘帀 luci-light / luci 瀵?oui銆乸ackage-manager 鐨勬媺鍙?#      锛堣繖淇╁湪 v3 閲岃 defconfig 寮哄埗鍔犲洖锛岀櫧鍗?~0.6MB锛?#   4) make defconfig 涔嬪悗锛屽啀寮哄埗鎶婁笂杩拌 SELECT 澶嶅師鐨勫寘鍏虫帀
# ==========================================================

set -e

# ---- 1) K2P 璁惧瀹氫箟锛歸pad-openssl -> wpad-basic-wolfssl ----
MK="target/linux/ramips/image/mt7621.mk"
if [ -f "$MK" ]; then
    sed -i 's/DEVICE_PACKAGES := -wpad-openssl -uboot-envtools/DEVICE_PACKAGES := wpad-basic-wolfssl -uboot-envtools/' "$MK"
    echo ">>> [diy-part2] K2P 璁惧瀹氫箟: wpad-openssl -> wpad-basic-wolfssl"
else
    echo ">>> [diy-part2] 鏈壘鍒?$MK锛岃烦杩?wpad 鏇挎崲"
fi

# ---- 2) OpenClash 鍘?ruby 渚濊禆 ----
OC=$(find . -path '*luci-app-openclash/Makefile' 2>/dev/null | head -1)
if [ -n "$OC" ]; then
    sed -i 's/+ruby-yaml//g; s/+ruby//g' "$OC"
    echo ">>> [diy-part2] OpenClash 宸茬Щ闄?+ruby 渚濊禆: $OC"
else
    echo ">>> [diy-part2] 鏈壘鍒?luci-app-openclash/Makefile锛坒eeds 鍙兘鏈畨瑁咃紵锛?
fi

# ---- 3) 鍘绘帀 luci 瀵?oui / package-manager 鐨勬媺鍙?----
LMK=$(find . -name Makefile -path '*feeds/luci*' 2>/dev/null | grep -E '/luci/Makefile$' | head -1)
if [ -n "$LMK" ]; then
    sed -i 's/+luci-app-oui//g; s/+luci-app-package-manager//g' "$LMK"
    echo ">>> [diy-part2] luci 宸茬Щ闄?oui/package-manager 渚濊禆: $LMK"
else
    echo ">>> [diy-part2] 鏈壘鍒?feeds/luci/Makefile"
fi

# ---- 4) defconfig 鍚庡己鍒跺叧琚?SELECT 澶嶅師鐨勫寘 ----
make defconfig
for p in luci-app-oui luci-app-package-manager luci-proto-ipv6; do
    sed -i "s/^CONFIG_PACKAGE_$p=y/# CONFIG_PACKAGE_$p is not set/" .config
done
echo ">>> [diy-part2] 瀹屾垚"
