# QR码工具 - 完全离线的 iOS 二维码应用

一款注重隐私安全的 iOS 二维码工具类应用，**零网络访问**，所有计算在设备本地完成。

## ✨ 功能

| 功能 | 描述 |
|------|------|
| 📝 **文本生成二维码** | 输入任意文本，实时生成高清二维码，支持保存到相册 |
| 📷 **相机扫码** | 调用系统相机实时识别二维码（iOS 16+ `DataScannerViewController`） |
| 🖼 **图片识别** | 从相册选取图片，识别其中的二维码文本 |
| 📋 **一键复制** | 识别结果支持一键复制到剪贴板 |

## 🔒 隐私安全承诺

- ✅ **零网络访问**：不使用 `URLSession` 或任何第三方网络库
- ✅ **本地计算**：所有数据处理在设备本地完成
- ✅ **无数据收集**：不追踪、不分析、不收集任何用户数据
- ✅ **无需注册**：无需用户注册或登录

## 🛠 技术栈

- **语言**：Swift 6
- **界面**：SwiftUI
- **架构**：MVVM
- **二维码生成**：`CIFilter(name: "CIQRCodeGenerator")`
- **相机扫码**：`DataScannerViewController` (iOS 16+)
- **图片识别**：`VNDetectBarcodesRequest` (Vision 框架)

## 📂 项目结构

```
QRCodeApp/
├── QRCodeApp.swift              # App 入口 + 隐私声明启动页
├── Info.plist                   # 权限声明（相机/相册）
├── Models/
│   └── QRModel.swift            # 数据模型
├── Services/
│   └── QRService.swift          # 核心服务（生成/识别/保存）
├── ViewModels/
│   ├── GenerateViewModel.swift  # 生成标签页 ViewModel
│   └── ScanViewModel.swift      # 扫描标签页 ViewModel
├── Views/
│   ├── ContentView.swift        # 主 TabView
│   ├── GenerateView.swift       # 生成界面
│   ├── ScanView.swift           # 扫描界面（含 DataScannerView）
│   └── ToastModifier.swift      # Toast 提示修饰器
└── Resources/
    └── Assets.xcassets/         # 资源文件
```

## 🚀 快速开始

### 方式一：Xcode 构建

1. 打开 Xcode → **File → New → Project**
2. 选择 **iOS → App**
3. 配置：
   - Product Name: `QRCodeApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Minimum Deployment: `iOS 16.0`
4. 将 `QRCodeApp/` 目录下的所有 `.swift` 文件拖入 Xcode 项目
5. 将 `QRCodeApp/Info.plist` 添加到项目配置的 Info 中
6. 将 `QRCodeApp/Resources/Assets.xcassets` 设置为项目 Assets
7. 连接真机运行（相机功能需要真机）

### 方式二：命令行构建（需 macOS + Xcode）

```bash
# 创建 Xcode 项目
swift package init --type executable  # 不适用 iOS
# 推荐直接在 Xcode 中创建项目后导入源码
```

### 方式三：GitHub Actions 自动构建

推送 tag 即可触发自动构建：

```bash
git tag v1.0.0
git push origin v1.0.0
```

构建产物：
- `.ipa`：可用于 SideStore / AltStore 安装
- `.tipa`：可用于 TrollStore 安装

## 📋 系统要求

- iOS 16.0+
- 真机设备（相机功能）
- A12 Bionic 或更新芯片（`DataScannerViewController` 要求）
