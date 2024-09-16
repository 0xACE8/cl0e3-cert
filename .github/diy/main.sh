#!/bin/bash

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
        echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}

#merge_package main https://github.com/shiyu1314/openwrt-onecloud target/linux kernel/6.6/amlogic
#merge_package master https://github.com/SySS-Research/clone-cert . *
git clone --depth 1 https://github.com/SySS-Research/clone-cert

# patch
sed -i 's/.cert/.crt/g' clone-cert.sh
sed -i 's\/tmp\/etc/tls.d\g' clone-cert.sh
#sed -i 's/hysteria-freebsd-arm64/hysteria-freebsd-arm64-avx/g' install-socks5-hysteria.sh
#sed -i 's/hysteria-freebsd-amd64/hysteria-freebsd-amd64-avx/g' install-socks5-hysteria.sh
#sed -i '4d' luci-app-wechatpush/root/usr/share/luci/menu.d/luci-app-wechatpush.json
#sed -i '4 i\\t\t"order": 60,' luci-app-wechatpush/root/usr/share/luci/menu.d/luci-app-wechatpush.json
#sed -i 's/, 30)/, 60)/g' feeds/ace8/luci-theme-serverchan/luasrc/controller/serverchan.lua
#sed -i "/minisign:minisign/d" luci-app-dnscrypt-proxy2/Makefile
#sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile
#sed -i "s/), 0)/), -1)/g" luci-app-passwall2/luasrc/controller/passwall2.lua
#sed -i "s/nil, 0)/nil, -1)/g" luci-app-passwall2/luasrc/controller/passwall2.lua
#sed -i 's/\(+luci-compat\)/\1 +luci-theme-design/' luci-app-design-config/Makefile
#sed -i 's/\(+luci-compat\)/\1 +luci-theme-argone/' luci-app-argone-config/Makefile

exit 0
