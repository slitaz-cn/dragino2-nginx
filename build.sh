#!/bin/bash
#
# This is free software, license use GPLv3.
#
# Copyright (c) 2021, Chuck <fanck0605@qq.com>
#

set -eu

proj_dir=$(pwd)

# clone openwrt
cd "$proj_dir"
rm -rf openwrt
git clone -b v19.07.7 https://github.com/openwrt/openwrt.git openwrt

# patch openwrt
cd "$proj_dir/openwrt"
cat "$proj_dir/patches"/*.patch | patch -p1

# obtain feed list
cd "$proj_dir/openwrt"
feed_list=$(awk '/^src-git/ { print $2 }' feeds.conf.default)

# clone feeds
cd "$proj_dir/openwrt"
./scripts/feeds update -a

# patch feeds
for feed in $feed_list; do
  [ -d "$proj_dir/patches/$feed" ] &&
    {
      cd "$proj_dir/openwrt/feeds/$feed"
      cat "$proj_dir/patches/$feed"/*.patch | patch -p1
    }
done

# addition packages
cd "$proj_dir/openwrt/package"
# luci-app-helloworld
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd custom/vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd custom/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ramfree custom/luci-app-ramfree
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-nfs custom/luci-app-nfs
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/wol custom/wol

# luci-theme-argon
git clone -b v2.2.5 --depth 1 https://github.com/jerrykuku/luci-theme-argon.git custom/luci-theme-argon

# clean up packages
cd "$proj_dir/openwrt/package"
find . -name .svn -exec rm -rf {} +
find . -name .git -exec rm -rf {} +

# zh_cn to zh_Hans
cd "$proj_dir/openwrt/package"
"$proj_dir/scripts/convert_translation.sh"

# install packages
cd "$proj_dir/openwrt"
./scripts/feeds install -a

# customize configs
cd "$proj_dir/openwrt"
cat "$proj_dir/config.seed" >.config
make defconfig

# build openwrt
cd "$proj_dir/openwrt"
make download -j8
make -j$(($(nproc) + 1)) || make -j1 V=s

# copy output files
cd "$proj_dir"
cp -a openwrt/bin/targets/*/* artifact
rm -rf artifact/packages
