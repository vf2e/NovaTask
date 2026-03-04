# NovaTask

NovaTask Elite 是一款基于 Qt 5.15.2 架构开发的高性能、现代化任务管理工具。它结合了 **Eisenhower Matrix** 决策法则与 **Nebula Glassmorphism** 视觉设计，旨在为用户提供极致的生产力管理体验。

## 核心特性

* **决策矩阵视图**：支持四象限任务分类，帮助用户科学排期。
* **极致视觉设计**：采用全屏动态流光背景、毛玻璃卡片质感以及深海色彩体系，营造沉浸式工作氛围。
* **高性能数据驱动**：底层采用 C++ `QAbstractListModel` 封装，实现海量任务下的 60fps 顺滑滚动与局部刷新。
* **持久化存储**：集成 SQLite 数据库，确保任务数据在本地安全存储，支持跨会话进度恢复。
* **物理感交互反馈**：内置非线性动画插值（Easing.OutBack）与智能 Toast 反馈系统。

## 技术栈

* **Framework**: Qt 5.15.2 (LTS)
* **Language**: C++ 11 & QML (Qt Quick 2.15)
* **UI Components**: Qt Quick Controls 2, Layouts, GraphicalEffects
* **Database**: SQLite 3 (QSQLITE 驱动)
* **Build System**: qmake / CMake

## 软件架构

项目遵循严格的 **MVC (Model-View-Controller)** 模式：
* **Model**: `TodoListModel.cpp` - 负责数据逻辑映射与信号通知。
* **View**: `main.qml` - 处理基于 GPU 加速的 UI 渲染与动效逻辑。
* **Controller**: `DatabaseManager.cpp` - 负责 SQLite 的 CRUD 线程安全操作。

## 快速开始

### 开发环境要求
* Qt 5.15.2 (MSVC 2019 / MinGW)
* Qt Creator 
* 确保安装时勾选了 `Qt Quick Controls 2` 与 `Qt Graphical Effects` 模块

### 构建步骤
1. 克隆本仓库：
   ```bash
   git clone [https://github.com/vf2e/NovaTask.git](https://github.com/vf2e/NovaTask.git)
    ```
2. 使用 Qt Creator 打开 NovaTask.pro 文件。

3. 在 .pro 文件中确认模块引用：

   ```bash
    QT += core gui quick sql quickcontrols2 graphicaleffects
    ```
4. 执行 qmake 并进行编译构建。

5. 运行生成的二进制文件。

### 数据库说明
数据库文件 novatask_core.db 存储于系统的 AppData 目录下。
表结构概要：

* id: INTEGER (PRIMARY KEY)

* title: TEXT (任务描述)

* priority: INTEGER (1-4 优先级)

* is_completed: INTEGER (0/1 状态)

* created_at: DATETIME

### 许可证
本项目基于 MIT License 开源。
