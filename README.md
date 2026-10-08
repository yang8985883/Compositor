# Compositor 中文版

> 本仓库是 [robbietilton/Compositor](https://github.com/robbietilton/Compositor) 的 fork，在上游 v1.4.6 的基础上完成了完整的简体中文（zh-Hans）本地化，并附带两个小的界面改进。英文原版说明见 [README.en.md](README.en.md)。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Adobe Photoshop 太贵，GIMP 这类工具又不够顺手。Compositor 就是为解决这个问题而生的——一个**完全免费开源**的全功能 macOS 图像编辑器，围绕 Photoshop 的合成与后期工作流打造，具备做出像素级成品所需的一切工具。

因为它是开源的，你可以随时下载源码，增删改任何功能来适应自己的工作流。本 fork 在其基础上：

- **完整简体中文界面**：1014 条界面文案全部汉化，采用 Photoshop 官方中文术语体系（正片叠底、色相/饱和度、内容识别填充、污点修复画笔……）
- **随系统语言自动切换**：系统语言是中文即显示中文，切回英文自动恢复英文，两种语言共存
- **工具栏即时名称提示**：鼠标悬停即刻显示工具名与快捷键，无需等待系统提示
- **文字工具图标修复**：自绘 "Aa" 图标，避免 macOS 在中文环境下把文字类符号渲染成「格式」
- **文档格式零改动**：`.comp` 工程文件、PSD 导入导出与上游完全兼容，旧文档直接打开

## 系统要求

- macOS 26.0 或更高版本的 Apple 芯片 Mac
- 从源码构建需要 Xcode 26 或更高版本

## 安装

### 从 Release 下载

到本仓库的 [Releases](https://github.com/yang8985883/Compositor/releases) 页面下载最新 DMG，拖入「应用程序」文件夹即可。

> 本 fork 的发行包为本地签名（未购买 Apple 开发者会员做公证），仅限自用；其他 Mac 上首次打开需右键 →「打开」绕过 Gatekeeper 提示。

### 从源码构建

```sh
git clone https://github.com/yang8985883/Compositor.git
cd Compositor
xcodebuild -project Compositor.xcodeproj -scheme Compositor -destination 'platform=macOS' build
```

或在 Xcode 中打开 `Compositor.xcodeproj`，直接运行 **Compositor** scheme。

## 维护与更新翻译

所有中文翻译集中在一个文件里，改动不需要触碰任何 Swift 代码：

- **翻译表**：[`scripts/zh-Hans.tsv`](scripts/zh-Hans.tsv) —— 一行一条 `英文<TAB>中文`
- **重新生成**：`python3 scripts/make_catalog.py`（把 TSV 编译成 `Compositor/Localizable.xcstrings` 字符串目录）
- **查漏**：`python3 scripts/extract_keys.py`（把尚未翻译的界面英文列到 `scripts/pending_keys.txt`）

上游发布新版本时：`git fetch upstream && git merge upstream/main`，重跑上面两个脚本补翻新增文案，再重新构建即可。

## 主要功能

### 图层
- 图层与文件夹，含不透明度和 Photoshop 全套混合模式（按其原有顺序）；文件夹不透明度会整体压暗内部内容
- 图层蒙版：可绘制、填充、反相、模糊和羽化，作用范围可超出图层自身像素；支持链接/取消链接以单独变换蒙版
- 剪贴蒙版与文件夹蒙版
- 调整图层：色相/饱和度、色阶、曲线、曝光、渐变映射、颗粒、黑白、色彩平衡、反相、高斯模糊、动感模糊和杂色
- 图层样式：描边、投影、颜色叠加、内阴影、外发光和内发光，GPU 渲染、随时可改
- 向下合并、合并图层、合并组（⌘E）
- 复制、内联重命名、拖拽排序与嵌套；按住 Option 拖拽复制；图层面板右键菜单
- 整层/整组拷贝粘贴（无选区时 ⌘C/⌘V），可跨项目，也可在项目间拖拽

### 变换
- 非破坏性的移动、缩放、旋转与翻转——无论缩多小，图像保留完整分辨率
- 自由扭曲（⌘ 拖动手柄），按住 Shift 锁定轴向
- 多图层、整个文件夹一起变换
- 吸附到画布和图层边缘与中心，带参考线
- 位置、尺寸、缩放和角度的精确数值输入，方向键步进
- 图层/画布的水平垂直翻转

### 选区
- 矩形和椭圆选框、自由和多边形套索、魔棒工具——魔棒按颜色选择，对象选择自动描出点击对象（Tab 切换）
- 选择主体；任意选区的扩展、收缩和羽化
- 选区相加相减、移动选框、移动或复制选区内的像素
- 载入图层像素或蒙版为选区
- 内容识别填充，还能向外扩展图像

### 绘画与修饰
- 画笔：大小、硬度、不透明度和平滑，绘画/擦除模式（B 和 E），Shift 画直线
- 污点修复画笔（内容识别）
- 仿制图章：对齐/不对齐，可取样单图层或全部图层
- 模糊工具，作用于像素或蒙版
- 渐变工具和形状工具（矩形、圆角矩形、椭圆、直线），保持可编辑不栅格化
- 文字工具（T）：可拖拽、可调大小的段落框内直接编辑多行文本；工具栏提供字体、字号、颜色、对齐和间距；文字可变换、可做剪贴蒙版
- 吸管工具和完整拾色器

### 调整与滤镜
- Camera Raw 滤镜：光、颜色、曲线、颜色混合器、颜色分级、细节、光学和几何，画布旁面板呈现
- 色阶（含自动）、曲线、色相/饱和度、曝光、渐变映射、颗粒、黑白、色彩平衡和反相
- 可扩散出图层边缘的高斯模糊和动感模糊
- 添加杂色、暗角、光晕/发光、色调对比、镜头校正和移除背景
- 实时预览，有选区时仅限于选区

### 画布与文件
- 多项目标签页
- 命令面板（⌘F）：像 Raycast 或 Obsidian 那样按名称搜索并执行任何菜单命令和工具
- 仅画布（F）：黑底全屏只显示画布，所有面板收起；再按 F 恢复
- 标尺（⌘R）、参考线、可调间距和细分的布局网格，以及参考线/网格/图层/文档边界吸附
- 裁剪带吸附，含 3:4、9:16 等比例，Option 对称裁剪；有选区时从选区起裁
- 画布大小、图像大小和修剪
- 缩小时清晰的高质量降采样，放大时的像素网格
- 导入 JPEG、PNG、HEIC、TIFF、SVG、相机 RAW（先显影）和 Photoshop PSD/PSB（8 位 RGB；不支持 CMYK）。Photoshop 的文件夹、蒙版、混合模式、填充矩形/椭圆和简单横排文字保持可编辑；其他矢量和竖排文字转为像素，应用前显示转换报告
- 大文档：内存预算随 Mac 自动调整；Photoshop 文件过大时改为将图层裁剪到画布再打开
- 导出 JPEG 带实时预览（⇧⌥⌘S）；合并拷贝
- 存储项目时不阻塞操作
- 全套 Photoshop 风格快捷键，可在「编辑 > 键盘快捷键」中自定义
- 数值标签可拖动微调，与 Photoshop 一致
- 自动更新（官方版；本 fork 构建请注意：更新会覆盖为上游英文版，建议在设置中关闭自动检查更新）

### 与 AI 代理协作
- AI 代理和脚本可以直接构建与编辑工程：`.comp` 是一个由 PNG 图层和清单组成的文件夹，工程打开时会随写入实时更新。参见 [编写 Compositor 工程](docs/writing-comp-files.md)（英文）

## 致谢

- 原作者 [Robbie Tilton](https://github.com/robbietilton) —— 本项目的全部核心工作来自上游 [robbietilton/Compositor](https://github.com/robbietilton/Compositor)
- 中文本地化基于 String Catalog 实现，翻译维护见上文「维护与更新翻译」

## 许可

MIT —— 见 [LICENSE](LICENSE)
