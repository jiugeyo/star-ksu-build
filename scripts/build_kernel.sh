#!/usr/bin/env bash
# Xiaomi 11 Ultra (star) 内核集成 SukiSU-Ultra (susfs-dev) 编译脚本
# 用法: ./build_kernel.sh [defconfig]
set -e

KERNEL_REPO="${KERNEL_REPO:-https://github.com/MiCode/Xiaomi_Kernel_OpenSource}"
KERNEL_BRANCH="${KERNEL_BRANCH:-star-r-oss}"
KSU_VARIANT="${KSU_VARIANT:-SukiSU-Ultra}"
KSU_BRANCH="${KSU_BRANCH:-susfs-dev}"
DEFCONFIG="${1:-$(ls arch/arm64/configs/ 2>/dev/null | grep -iE 'star|lahaina' | head -1)}"

echo "==> 内核仓库: $KERNEL_REPO @ $KERNEL_BRANCH"
echo "==> SukiSU:   $KSU_VARIANT @ $KSU_BRANCH"
echo "==> defconfig: ${DEFCONFIG:-自动探测}"

if [ ! -f "Makefile" ] || [ ! -d "scripts" ]; then
  echo "==> 拉取内核源码..."
  git clone --depth=1 -b "$KERNEL_BRANCH" "$KERNEL_REPO" src
  cd src
else
  cd "$(dirname "$0")/.."
  [ -d src ] || { echo "src 目录不存在，请先克隆内核源码到 src/"; exit 1; }
  cd src
fi

# 集成 SukiSU-Ultra (susfs-dev 已内置 SUSFS，非 GKI 自动 hook)
if [ ! -d "KernelSU" ]; then
  echo "==> 集成 $KSU_VARIANT..."
  curl -LSs "https://raw.githubusercontent.com/$KSU_VARIANT/$KSU_VARIANT/main/setup.sh" -o setup.sh
  chmod +x setup.sh
  ./setup.sh "$KSU_BRANCH"
fi

# 确保非 GKI 必需符号
scripts/config --file arch/arm64/configs/${DEFCONFIG} \
  --set-val CONFIG_KALLSYMS y \
  --set-val CONFIG_KALLSYMS_ALL y \
  --set-val CONFIG_KPM y || true

# 编译 (优先 Clang，回退 GCC)
if command -v clang >/dev/null 2>&1; then
  export LLVM=1 LLVM_IAS=1
  MAKE=(make -j"$(nproc)" ARCH=arm64 CC=clang CROSS_COMPILE=aarch64-linux-gnu-)
else
  MAKE=(make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-)
fi

"${MAKE[@]}" "$DEFCONFIG"
"${MAKE[@]}" Image dtbs 2>&1 | tee build.log

echo "==> 编译完成，产物在 src/arch/arm64/boot/Image"
echo "==> 使用 AnyKernel3 打包: 将 Image 与 dtb 放入 anykernel/ 并执行其打包脚本"
