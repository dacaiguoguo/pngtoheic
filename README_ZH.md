# PNG 转 HEIC 转换工具

这个 Swift 命令行工具可以处理指定文件夹中的图片资源，将 PNG 格式的图片转换为 HEIC 格式。该工具专门处理 macOS 和 iOS 项目中常用的 `.xcassets` 文件夹，并更新 `Contents.json` 文件以引用新的 HEIC 图片，同时删除原始的 PNG 文件。

## 功能
- 将 PNG 图片转换为 HEIC 格式，支持自定义压缩质量。
- 自动更新 `Contents.json` 文件，指向新的 HEIC 图片。
- 成功转换后删除原始 PNG 文件。
- 处理指定文件夹中的所有 JSON 文件，识别并转换图片。

## 前提条件
- 安装了 Swift 的 macOS 系统。
- 需要 Xcode 或兼容的 Swift 工具链。
- 要处理的文件夹应该包含有效的 `Contents.json` 文件，该文件定义了使用的图片。

## 安装
1. 确保系统已安装 Swift。
2. 将脚本克隆或复制到一个文件中，例如命名为 `png2heic.swift`。
3. 使用 Swift 的命令行工具编译脚本：

   ```bash
   swiftc png2heic.swift -o png2heic
   ```

## 使用方法
1. 编译脚本后，运行生成的可执行文件，并传递文件夹路径作为参数：

   ```bash
   ./png2heic /path/to/your/assets.xcassets
   ```

   示例：

   ```bash
   ./png2heic /Users/youruser/Developer/Project/Assets.xcassets
   ```

2. 工具将执行以下操作：
   - 将 `Contents.json` 文件中引用的 PNG 图片转换为 HEIC 格式。
   - 更新 `Contents.json` 文件，引用新的 HEIC 图片。
   - 删除原始的 PNG 图片。

3. 脚本执行完毕后，会显示处理完成的提示信息。

## 代码概述

### 主要函数

1. **`processImagesInFolder(fromFolderPath:fileType:)`**:
   - 遍历指定文件夹，识别 JSON 文件（如 `Contents.json`），并处理图片数据。
   - 对于 `Contents.json` 文件中列出的每张图片，将 PNG 图片转换为 HEIC 格式，并更新 JSON 文件。

2. **`getFilesAsJSON(fromFolderPath:fileType:)`**:
   - 枚举文件夹中的文件，收集所有 JSON 文件（或指定类型的文件）以进行进一步处理。

3. **`convertPNGToHEIC(pngImageData:quality:)`**:
   - 将 PNG 图片数据转换为 HEIC 格式，并支持自定义压缩质量（默认：1.0）。

### 错误处理
该工具包括基本的错误处理，如：
- 解析 JSON 文件失败。
- 找不到图片文件。
- HEIC 转换或文件写入操作时出现错误。

## 依赖
- **AppKit**：用于处理图片转换。
- **ImageIO**：用于生成 HEIC 文件。
- **UniformTypeIdentifiers**：用于处理 HEIC 输出的现代类型标识符。

## 许可证
该项目采用 MIT 许可证开源。您可以自由使用、修改和分发此代码，但需保留适当的版权声明。

---

欢迎根据您的需求自定义此脚本，进行更多高级用例或优化！