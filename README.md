# ZHHPickerView

[![Version](https://img.shields.io/cocoapods/v/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)
[![License](https://img.shields.io/cocoapods/l/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)
[![Platform](https://img.shields.io/cocoapods/p/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)

基于 UIPickerView 的 iOS 底部弹窗选择器，**Swift** 实现，支持日期选择器与字符串选择器（单列 / 多列 / 联动）。

## 目录

- [特性](#特性)
- [截图展示](#截图展示)
- [要求](#要求)
- [安装](#安装)
- [快速开始](#快速开始)
- [使用示例](#使用示例)
- [API 文档](#api-文档)
- [示例项目](#示例项目)
- [许可证](#许可证)

## ✨ 特性

### 日期选择器

- **系统样式**：支持 `UIDatePicker` 的系统样式（年月日、年月日时分、时分、倒计时）
- **自定义样式**：支持多种自定义日期格式
  - 年月日时分秒（yyyy-MM-dd HH:mm:ss）
  - 年月日时分（yyyy-MM-dd HH:mm）
  - 年月日（yyyy-MM-dd）
  - 年月（yyyy-MM）
  - 年（yyyy）
  - 时分秒（HH:mm:ss）
  - 时分（HH:mm）
  - 年-季度（yyyy-QQ）
  - 年月周（yyyy-MM-ww）
  - 年周（yyyy-ww）
  - 等多种格式
- **日期限制**：支持设置最小日期、最大日期
- **默认选中**：支持设置默认选中的日期
- **国际化**：内置多语言支持（中文、英文、繁体中文）

### 字符串选择器

- **单列选择**：支持单列数据选择
- **多列选择**：支持多列独立数据选择
- **多级联动**：支持多级联动数据选择
- **数据源**：支持代码配置和 JSON 文件两种数据源方式
- **行政区划**：内置省市区数据支持

### 基础效果

- **自定义样式**：支持自定义标题、按钮、颜色、字体等
- **灵活布局**：支持自定义高度、边距、对齐方式等
- **交互配置**：支持显示/隐藏取消按钮、分割线等

## 截图展示

### 基础效果

展示各种基础样式配置和自定义选项。

<div align="left">
  <img src="screenshots/basic-effect-1.png" width="150" alt="基础效果1">
  <img src="screenshots/basic-effect-2.png" width="150" alt="基础效果2">
  <img src="screenshots/basic-effect-3.png" width="150" alt="基础效果3">
  <img src="screenshots/basic-effect-4.png" width="150" alt="基础效果4">
</div>

### 字符串选择器

#### 单列选择器

<div align="left">
  <img src="screenshots/string-picker-single.png" width="150" alt="单列选择器">
</div>

#### 多列选择器

<div align="left">
  <img src="screenshots/string-picker-multiple-2.png" width="150" alt="两列选择器">
  <img src="screenshots/string-picker-multiple-3.png" width="150" alt="三列选择器">
</div>

#### 联动选择器

<div align="left">
  <img src="screenshots/string-picker-cascade-2.png" width="150" alt="两列联动">
  <img src="screenshots/string-picker-cascade-3.png" width="150" alt="三列联动">
</div>

#### 行政区划 - 单层级

<div align="left">
  <img src="screenshots/region-province.png" width="150" alt="省级">
  <img src="screenshots/region-city.png" width="150" alt="地级">
  <img src="screenshots/region-area.png" width="150" alt="县级">
  <img src="screenshots/region-street.png" width="150" alt="乡级">
  <img src="screenshots/region-village.png" width="150" alt="村级">
</div>

#### 行政区划 - 多级联动

<div align="left">
  <img src="screenshots/region-pc-code.png" width="150" alt="省份城市二级联动">
  <img src="screenshots/region-pca-code.png" width="150" alt="省份城市区县三级联动">
  <img src="screenshots/region-pcas-code.png" width="150" alt="省份城市区县乡镇四级联动">
</div>

### 日期选择器

#### 系统样式

<div align="left">
  <img src="screenshots/date-picker-system-date.png" width="150" alt="年月日">
  <img src="screenshots/date-picker-system-date-time.png" width="150" alt="年月日时分">
  <img src="screenshots/date-picker-system-time.png" width="150" alt="时分">
  <img src="screenshots/date-picker-system-countdown.png" width="150" alt="倒计时">
</div>

#### 自定义样式

<div align="left">
  <img src="screenshots/date-picker-ymdhms.png" width="150" alt="年月日时分秒">
  <img src="screenshots/date-picker-ymdhm.png" width="150" alt="年月日时分">
  <img src="screenshots/date-picker-ymdh.png" width="150" alt="年月日时">
  <img src="screenshots/date-picker-mdhm.png" width="150" alt="月日时分">
  <img src="screenshots/date-picker-ymd.png" width="150" alt="年月日">
  <img src="screenshots/date-picker-ym.png" width="150" alt="年月">
  <img src="screenshots/date-picker-y.png" width="150" alt="年">
  <img src="screenshots/date-picker-md.png" width="150" alt="月日">
  <img src="screenshots/date-picker-hms.png" width="150" alt="时分秒">
  <img src="screenshots/date-picker-hm.png" width="150" alt="时分">
  <img src="screenshots/date-picker-ms.png" width="150" alt="分秒">
  <img src="screenshots/date-picker-yq.png" width="150" alt="年-季度">
  <img src="screenshots/date-picker-ymw.png" width="150" alt="年月周">
  <img src="screenshots/date-picker-yw.png" width="150" alt="年周">
  <img src="screenshots/date-picker-custom-extra.png" width="150" alt="日期选择器示例">
</div>

## 要求

- iOS 13.0+
- Swift 5.0+

**版本说明**：Swift 实现请使用 **1.0.0 及以上**版本；Objective-C请使用当前仓库内 0.x 的最新版本（Objective-C 实现）。

## 安装

### CocoaPods

```ruby
pod 'ZHHPickerView'
# 或
pod 'ZHHPickerView/Core'
```

按需安装子模块：

```ruby
pod 'ZHHPickerView/DatePicker'   # 日期选择器（含 Base）
pod 'ZHHPickerView/StringPicker' # 字符串选择器（含 Base）
pod 'ZHHPickerView/Base'          # 仅基础模块
```

然后执行：

```bash
pod install
```

## 快速开始

### 日期选择器

```swift
import ZHHPickerView

// 创建日期选择器
let picker = DatePickerView(pickerMode: .ymd)

// 设置默认选中日期
picker.selectedDate = Date()

// 设置日期范围（可选）
let calendar = Calendar.current
picker.minDate = calendar.date(byAdding: .year, value: -18, to: Date())
picker.maxDate = calendar.date(byAdding: .year, value: 18, to: Date())

// 设置结果回调
picker.resultBlock = { date, value in
    print("选中的日期：\(value ?? "")")
}

// 显示选择器
picker.show()
```

### 字符串选择器

**单列**

```swift
let picker = StringPickerView(pickerMode: .single)
picker.dataSource = ["选项1", "选项2", "选项3"]
picker.selectedIndex = 0
picker.singleResultBlock = { model, index in
    print("选中：\(model?.text ?? "")")
}
picker.show()
```

**多列**

```swift
let picker = StringPickerView(pickerMode: .multiple)
picker.dataSource = [
    ["A1", "A2", "A3"],
    ["B1", "B2", "B3"]
]
picker.multiResultBlock = { models, indexes in
    // 处理多列结果
}
picker.show()
```

**联动**

```swift
let picker = StringPickerView(pickerMode: .cascade)
let parent = StringPickerModel()
parent.text = "父级"
parent.children = [
    .model(index: 0, text: "子级1"),
    .model(index: 1, text: "子级2")
]
picker.dataSource = [parent]
picker.show()
```

## 日期选择器模式（DatePickerMode）

- 系统样式：`.date`、`.dateAndTime`、`.time`、`.countDownTimer`
- 自定义：`.ymdHMS`、`.ymdHM`、`.ymdH`、`.mdHM`、`.ymd`、`.ym`、`.y`、`.md`、`.hMS`、`.hM`、`.mS`

## 字符串选择器模式（StringPickerMode）

- `.single` 单列
- `.multiple` 多列
- `.cascade` 多级联动

## 自定义样式（BasePickerView）

```swift
let picker = BasePickerView()
picker.titleLabel?.text = "选择器标题"
picker.pickerViewHeight = 400
picker.pickerHeaderViewHeight = 50
picker.show()
```

## 示例项目

```bash
cd Example
pod install
open ZHHPickerView.xcworkspace
```

示例包含：基础样式、字符串选择器（单列 / 多列 / 联动）、日期选择器（多种模式）。

## 许可证

MIT，见 [LICENSE](LICENSE)。

## 作者

桃色三岁，136769890@qq.com
