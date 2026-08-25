# star-ksu-build

小米 11 Ultra (star) 内核集成 **SukiSU-Ultra + SUSFS** 的云端构建工程。

- 内核源码：`MiCode/Xiaomi_Kernel_OpenSource` 分支 `star-r-oss`（Android R / SM8350）
- SukiSU-Ultra 分支：`susfs-dev`（官方已集成 SUSFS，支持非 GKI）
- 构建方式：GitHub Actions 云编译 → 产出 AnyKernel3 卡刷 zip

## 目录结构

```
.github/workflows/build-star-ksu.yml   # GitHub Actions 工作流（Actions 页面可识别）
scripts/build_kernel.sh                # 本地/自托管 Linux 编译脚本
push.ps1                               # Windows PowerShell 一键推送到 GitHub
push.sh                                # Git Bash / Linux / macOS 推送脚本
README.md
```

## 快速开始（推送到你的 GitHub）

### Windows（推荐 PowerShell）

1. 将本目录放到一个**不含中文/空格**的路径（如 `D:\star-ksu`）。
2. 若首次运行 PowerShell 脚本被阻止，先以**管理员身份**打开 PowerShell 执行一次：
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```
3. 双击 `push.ps1`，或在 PowerShell 中：
   ```powershell
   cd D:\star-ksu
   .\push.ps1
   ```
4. 提示输入凭证时：
   - **用户名**：你的 GitHub 用户名（如 `jiugeyo`）
   - **密码**：填你的 Personal Access Token（`ghp_` 开头，**不是 GitHub 登录密码**）

### Git Bash / Linux / macOS

```bash
cd star-ksu-build
git config user.email "you@example.com"   # 首次需配置身份
git config user.name  "Your Name"
bash push.sh
```

## 触发云编译

推送成功后：

1. 打开 `https://github.com/<你的用户名>/star-ksu-build` → **Actions**。
2. 选择工作流 **Build Xiaomi 11 Ultra (star) Kernel with SukiSU-Ultra + SUSFS** → **Run workflow**。
3. 参数默认 `kernel_branch=star-r-oss`、`susfs=true`，直接运行。
4. 约 20–60 分钟后，下载产物 `Xiaomi11Ultra-star-SukiSU-Ultra-SUSFS.zip`。

## 刷入与验证

Recovery 卡刷 / `adb sideload Xiaomi11Ultra-star-SukiSU-Ultra-SUSFS.zip` → 重启 →
用 **SukiSU Manager** App 查看，确认 SUSFS 状态为「已启用 / Supported」。

## 注意

- `star-r-oss` 为 Android 11 基线。若你的 ROM（如澎湃 1.0.21.0，Android 14）刷入后异常，
  在 workflow 运行界面把 `kernel_branch` 改为与 ROM 安全补丁月份更接近的 tag 重跑即可。
- 刷机有变砖风险：请先备份数据、确认已解锁 Bootloader，并备好官方线刷包以便回退。
