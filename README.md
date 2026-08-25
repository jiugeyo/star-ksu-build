# star-ksu-build

Xiaomi 11 Ultra (`star`) 内核集成 **SukiSU-Ultra** (分支 `susfs-dev`，内置 SUSFS) + **AnyKernel3** 打包的 GitHub Actions 云端构建工程。

## 一键推送到你的 GitHub（Windows / PowerShell）

1. 以**管理员身份**打开 PowerShell，解除脚本运行限制（仅首次）：
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```
2. 在 PowerShell 中进入本文件夹，运行：
   ```powershell
   .\push.ps1
   ```
3. 凭证提示：**用户名 `jiugeyo`，密码填 `ghp_` 开头的 Personal Access Token**。
4. 推送成功后打开 <https://github.com/jiugeyo/star-ksu-build> → **Actions** → 选
   **Build Xiaomi 11 Ultra (star) Kernel with SukiSU-Ultra + SUSFS** → **Run workflow**
   （参数默认 `kernel_branch=star-r-oss`、`susfs=true`）。
5. 约 20–60 分钟后下载产物 `Xiaomi11Ultra-star-SukiSU-Ultra-SUSFS.zip`，
   Recovery 卡刷 / `adb sideload` 后重启，用 SukiSU Manager 验证 SUSFS 已启用。

## 本地编译（自托管 Linux）

```bash
sudo apt install -y bc bison cpio flex kmod libelf-dev libssl-dev libtfm-dev \
    libzstd-dev pahole xz-utils zlib1g-dev clang llvm lld
export KERNEL_SOURCE="https://github.com/MiCode/Xiaomi_Kernel_OpenSource"
export KERNEL_BRANCH="star-r-oss"
export DEVICE_NAME="star"
bash scripts/build_kernel.sh
```

## 参数说明（Actions 运行界面可覆盖）

| 参数 | 默认 | 说明 |
|---|---|---|
| `kernel_branch` | `star-r-oss` | 小米内核源码分支/tag |
| `susfs` | `true` | 启用 SUSFS（SukiSU-Ultra susfs-dev 内置） |
| `release` | `false` | `true` 时构建完成后自动创建 GitHub Release |

## 注意

- `star-r-oss` 为 Android 11 基线。澎湃 1.0.21.0 基于 Android 14，若刷入后异常，
  在 workflow 运行界面把 `kernel_branch` 改为与 1.0.21.0 安全补丁月份更接近的 tag 重跑。
- 刷机前请备份数据、确认已解锁 Bootloader，并准备好官方线刷包以便回退。
