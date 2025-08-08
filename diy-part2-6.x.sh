#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 修改uhttpd配置文件，启用nginx
# sed -i "/.*uhttpd.*/d" .config
# sed -i '/.*\/etc\/init.d.*/d' package/network/services/uhttpd/Makefile
# sed -i '/.*.\/files\/uhttpd.init.*/d' package/network/services/uhttpd/Makefile
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config
cp -a $GITHUB_WORKSPACE/configfiles/etc/* package/base-files/files/etc/
# ls package/base-files/files/etc/


# 集成CPU性能跑分脚本
cp -a $GITHUB_WORKSPACE/configfiles/coremark/* package/base-files/files/bin/
chmod 755 package/base-files/files/bin/coremark
chmod 755 package/base-files/files/bin/coremark.sh


# 定时限速插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus

# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Set Rust build arg llvm.download-ci-llvm to false.
RUST_MAKEFILE="feeds/packages/lang/rust/Makefile"
if [[ -f "${RUST_MAKEFILE}" ]]; then
  printf "Modifying %s...\n" "${RUST_MAKEFILE}"
  sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' "${RUST_MAKEFILE}"
else
  echo "File ${RUST_MAKEFILE} does not exist." >&2
fi

# 更新 golang 1.24 版本
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}

#git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-turboacc

# 科学上网插件
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall
#git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-homeproxy


