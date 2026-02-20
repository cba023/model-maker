# Model Maker

<div align="center">

**🚀 专业的 iOS 数据模型代码生成工具**

[![Web Version](https://img.shields.io/badge/Web-Version-blue)](https://model-maker.github.io/)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20macOS%20%7C%20Multi-lightgrey)](https://model-maker.github.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[在线体验](https://model-maker.github.io/) · [功能特性](#-功能特性) · [快速开始](#-快速开始)

</div>

---

## 📖 项目简介

Model Maker 是一款专为 iOS 开发团队设计的数据模型代码生成工具，能够根据 JSON 数据或 API 接口文档自动生成 Swift/Objective-C 模型代码。支持多种主流序列化框架，显著提升开发效率，减少重复编码工作。

## ✨ 功能特性

### 🔧 核心功能

- **📝 多格式输入支持**
  - JSON 数据自动解析
  - Swagger/API 接口文档解析
  - Markdown 表格格式支持
  - 自动提取接口路径并生成模型名

- **🎯 多种序列化框架支持**
  - ✅ **SmartCodable** - 强大的类型安全序列化框架
  - ✅ **YYModel** - 高性能模型转换框架
  - ✅ **原生 Codable** - Swift 标准序列化协议
  - ✅ **Objective-C 兼容** - 完整支持 OC 项目

- **⚙️ 高级特性**
  - 🔄 智能模型去重 - 自动识别相同结构的模型
  - 🏗️ 构造方法生成 - 支持自定义初始化方法
  - 📚 自动注释生成 - 从文档中提取字段说明
  - 🔀 驼峰命名转换 - 支持 snake_case 到 camelCase 自动转换
  - 🌐 多平台支持 - 官方提供 Web 版本和 macOS 原生应用，基于 Flutter 构建，可自行编译 Windows、Linux、Android、iOS 等所有 Flutter 支持的平台

### 🎨 用户体验

- 🎯 实时预览 - 输入即时生成代码预览
- 📋 一键复制 - 快速复制生成的代码
- 🎨 代码高亮 - 语法高亮显示，易于阅读
- 📱 响应式设计 - 完美适配各种屏幕尺寸

## 🚀 快速开始

### 在线使用

直接访问 [https://model-maker.github.io/](https://model-maker.github.io/) 即可开始使用，无需安装任何软件。

### 本地运行

```bash
# 克隆项目
git clone https://github.com/model-maker/model-maker.git

# 进入项目目录
cd model-maker

# 安装依赖
flutter pub get

# 运行 Web 版本
flutter run -d chrome

# 或运行 macOS 版本
flutter run -d macos

# 编译其他平台版本
# Windows
flutter build windows

# Linux
flutter build linux

# Android
flutter build apk

# iOS (需要 macOS 和 Xcode)
flutter build ios
```

> 💡 **提示**：本项目基于 Flutter 构建，理论上支持所有 Flutter 支持的平台。官方主要维护 Web 和 macOS 版本，其他平台可以自行编译使用。

## 📖 使用指南

### 1. JSON 数据生成模型

直接将 JSON 数据粘贴到输入框，工具会自动解析并生成对应的 Swift 模型代码。

**示例输入：**
```json
{
  "id": 12345,
  "name": "张三",
  "email": "zhangsan@example.com",
  "is_active": true
}
```

### 2. API 文档生成模型

支持解析包含接口地址的 Markdown 文档，自动提取 API 路径并生成模型名。

**示例文档格式：**

<pre>
## 用户信息接口

**接口地址** `/api/user/info`

**响应示例**
```json
{
  "id": 12345,
  "name": "张三"
}
```
</pre>

### 3. 配置选项

- **使用驼峰命名** - 将 snake_case 转换为 camelCase
- **使用结构体** - 生成 struct 而非 class
- **支持 Objective-C** - 生成 OC 兼容代码
- **支持 SmartCodable** - 使用 SmartCodable 框架
- **支持 YYModel** - 使用 YYModel 框架
- **原生 Codable** - 使用 Swift 原生 Codable
- **(Smart)Codable映射** - 启用 JSONKey 映射，支持自定义字段名映射规则
- **支持 public** - 添加 public 访问修饰符
- **生成构造方法** - 自动生成初始化方法
- **反序列化静态方法** - 生成静态的反序列化方法（如 fromJSON()），方便在外部调用时直接解析 JSON 返回的数据生成数据模型
- **Swagger接口文档** - 勾选：启用 Swagger 接口文档解析模式；未勾选：启用 Knife4j 增强版接口文档解析模式

## 🛠️ 技术栈

- **Flutter** - 跨平台 UI 框架
- **Dart** - 编程语言
- **Provider** - 状态管理
- **Flutter Code Editor** - 代码编辑器组件

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 [MIT](LICENSE) 许可证。

## 🔗 相关链接

- 🌐 [在线版本](https://model-maker.github.io/)
- 📦 [macOS 版本](https://github.com/cba023/model-maker/releases/)
- 🐛 [问题反馈](https://github.com/cba023/model-maker/issues)

---

<div align="center">
**⭐ 如果这个项目对你有帮助，请给个 Star ⭐**
</div>
