# ZHHPickerView

[![CI Status](https://img.shields.io/travis/yue5yueliang/ZHHPickerView.svg?style=flat)](https://travis-ci.org/yue5yueliang/ZHHPickerView)
[![Version](https://img.shields.io/cocoapods/v/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)
[![License](https://img.shields.io/cocoapods/l/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)
[![Platform](https://img.shields.io/cocoapods/p/ZHHPickerView.svg?style=flat)](https://cocoapods.org/pods/ZHHPickerView)

一个功能强大、易于使用的 iOS 选择器组件，支持日期选择器和字符串选择器。

## 📋 目录

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

### 📅 日期选择器

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

### 📝 字符串选择器

- **单列选择**：支持单列数据选择
- **多列选择**：支持多列独立数据选择
- **多级联动**：支持多级联动数据选择
- **数据源**：支持代码配置和 JSON 文件两种数据源方式
- **行政区划**：内置省市区数据支持

### 🎨 基础效果

- **自定义样式**：支持自定义标题、按钮、颜色、字体等
- **灵活布局**：支持自定义高度、边距、对齐方式等
- **交互配置**：支持显示/隐藏取消按钮、分割线等

## 📸 截图展示

### 基础效果

展示各种基础样式配置和自定义选项。

<div align="center">
  <img src="screenshots/basic-effect-1.png" width="200" alt="基础效果1">
  <img src="screenshots/basic-effect-2.png" width="200" alt="基础效果2">
  <img src="screenshots/basic-effect-3.png" width="200" alt="基础效果3">
  <img src="screenshots/basic-effect-4.png" width="200" alt="基础效果4">
</div>

### 字符串选择器

#### 单列选择器

<div align="center">
  <img src="screenshots/string-picker-single.png" width="200" alt="单列选择器">
</div>

#### 多列选择器

<div align="center">
  <img src="screenshots/string-picker-multiple-2.png" width="200" alt="两列选择器">
  <img src="screenshots/string-picker-multiple-3.png" width="200" alt="三列选择器">
</div>

#### 联动选择器

<div align="center">
  <img src="screenshots/string-picker-cascade-2.png" width="200" alt="两列联动">
  <img src="screenshots/string-picker-cascade-3.png" width="200" alt="三列联动">
</div>

#### 行政区划 - 单层级

<div align="center">
  <img src="screenshots/region-province.png" width="200" alt="省级">
  <img src="screenshots/region-city.png" width="200" alt="地级">
  <img src="screenshots/region-area.png" width="200" alt="县级">
  <img src="screenshots/region-street.png" width="200" alt="乡级">
  <img src="screenshots/region-village.png" width="200" alt="村级">
</div>

#### 行政区划 - 多级联动

<div align="center">
  <img src="screenshots/region-pc-code.png" width="200" alt="省份城市二级联动">
  <img src="screenshots/region-pca-code.png" width="200" alt="省份城市区县三级联动">
  <img src="screenshots/region-pcas-code.png" width="200" alt="省份城市区县乡镇四级联动">
</div>

### 日期选择器

#### 系统样式

<div align="center">
  <img src="screenshots/date-picker-system-date.png" width="200" alt="年月日">
  <img src="screenshots/date-picker-system-date-time.png" width="200" alt="年月日时分">
  <img src="screenshots/date-picker-system-time.png" width="200" alt="时分">
  <img src="screenshots/date-picker-system-countdown.png" width="200" alt="倒计时">
</div>

#### 自定义样式

<div align="center">
  <img src="screenshots/date-picker-ymdhms.png" width="200" alt="年月日时分秒">
  <img src="screenshots/date-picker-ymdhm.png" width="200" alt="年月日时分">
  <img src="screenshots/date-picker-ymdh.png" width="200" alt="年月日时">
  <img src="screenshots/date-picker-mdhm.png" width="200" alt="月日时分">
  <img src="screenshots/date-picker-ymd.png" width="200" alt="年月日">
  <img src="screenshots/date-picker-ym.png" width="200" alt="年月">
  <img src="screenshots/date-picker-y.png" width="200" alt="年">
  <img src="screenshots/date-picker-md.png" width="200" alt="月日">
  <img src="screenshots/date-picker-hms.png" width="200" alt="时分秒">
  <img src="screenshots/date-picker-hm.png" width="200" alt="时分">
  <img src="screenshots/date-picker-ms.png" width="200" alt="分秒">
  <img src="screenshots/date-picker-yq.png" width="200" alt="年-季度">
  <img src="screenshots/date-picker-ymw.png" width="200" alt="年月周">
  <img src="screenshots/date-picker-yw.png" width="200" alt="年周">
  <img src="screenshots/date-picker-custom-extra.png" width="200" alt="日期选择器示例">
</div>

## 📱 要求

- iOS 13.0+
- Xcode 12.0+
- Objective-C

## 🔧 安装

### CocoaPods

#### 安装完整功能（推荐）

在 `Podfile` 中添加：

```ruby
pod 'ZHHPickerView'
# 或
pod 'ZHHPickerView/Core'
```

#### 按需安装子模块

如果你只需要部分功能，可以只安装对应的子模块：

```ruby
# 只安装日期选择器（会自动包含 Base 模块）
pod 'ZHHPickerView/DatePicker'

# 只安装字符串选择器（会自动包含 Base 模块）
pod 'ZHHPickerView/StringPicker'

# 只安装基础模块
pod 'ZHHPickerView/Base'
```

**注意**：`DatePicker` 和 `StringPicker` 模块会自动依赖 `Base` 模块，无需单独安装。

然后运行：

```bash
pod install
```

## 🚀 快速开始

### 日期选择器

```objc
#import "ZHHDatePickerView.h"

// 创建日期选择器
ZHHDatePickerView *pickerView = [[ZHHDatePickerView alloc] initWithPickerMode:ZHHDatePickerModeYMD];

// 设置默认选中日期
pickerView.selectedDate = [NSDate date];

// 设置日期范围（可选）
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDateComponents *components = [[NSDateComponents alloc] init];
components.year = -18;
pickerView.minDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
components.year = 18;
pickerView.maxDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];

// 设置结果回调
pickerView.resultBlock = ^(NSDate * _Nullable selectedDate, NSString * _Nullable selectedValue) {
    NSLog(@"选中的日期：%@", selectedValue);
};

// 显示选择器
[pickerView show];
```

### 字符串选择器

#### 单列选择

```objc
#import "ZHHStringPickerView.h"

ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeSingle];
pickerView.dataSource = @[@"选项1", @"选项2", @"选项3"];
pickerView.selectedIndex = 0;

pickerView.singleResultBlock = ^(ZHHStringPickerModel * _Nullable model, NSInteger index) {
    NSLog(@"选中的选项：%@", model.text);
};

[pickerView show];
```

#### 多列选择

```objc
ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeMultiple];
pickerView.dataSource = @[
    @[@"选项1-1", @"选项1-2", @"选项1-3"],
    @[@"选项2-1", @"选项2-2", @"选项2-3"]
];

pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
    // 处理多列选择结果
};

[pickerView show];
```

#### 多级联动

```objc
ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];

// 构建联动数据
ZHHStringPickerModel *parent = [[ZHHStringPickerModel alloc] init];
parent.text = @"父级";
parent.children = @[
    [ZHHStringPickerModel modelWithIndex:0 text:@"子级1"],
    [ZHHStringPickerModel modelWithIndex:1 text:@"子级2"]
];

pickerView.dataSource = @[parent];
[pickerView show];
```

## 📖 使用示例

### 日期选择器模式

```objc
// 系统样式
ZHHDatePickerView *pickerView = [[ZHHDatePickerView alloc] initWithPickerMode:ZHHDatePickerModeDate];
[pickerView show];

// 自定义样式
ZHHDatePickerView *pickerView = [[ZHHDatePickerView alloc] initWithPickerMode:ZHHDatePickerModeYMDHMS];
pickerView.selectedDate = [NSDate date];
pickerView.minDate = ...; // 设置最小日期
pickerView.maxDate = ...; // 设置最大日期
[pickerView show];
```

### 字符串选择器模式

```objc
// 单列
ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeSingle];

// 多列
ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeMultiple];

// 多级联动
ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];
```

### 自定义样式

```objc
ZHHBasePickerView *pickerView = [[ZHHBasePickerView alloc] init];
pickerView.titleLabel.text = @"选择器标题";
pickerView.pickerViewHeight = 400;
pickerView.pickerHeaderViewHeight = 50;
pickerView.cancelButton.backgroundColor = UIColor.systemTealColor;
pickerView.confirmButton.backgroundColor = UIColor.systemBrownColor;
[pickerView show];
```

## 📚 API 文档

### ZHHDatePickerView

#### 主要属性

- `pickerMode`: 日期选择器模式
- `selectedDate`: 当前选中的日期
- `minDate`: 最小日期
- `maxDate`: 最大日期
- `isAutoSelect`: 是否自动选择
- `resultBlock`: 选择结果回调

#### 显示配置

- `unitDisplayType`: 日期单位显示类型
- `showWeek`: 是否显示"星期"
- `showToday`: 是否显示"今天"
- `showLeadingZero`: 是否显示前导零
- `customUnit`: 自定义日期单位显示

### ZHHStringPickerView

#### 主要属性

- `pickerMode`: 字符串选择器模式（单列/多列/联动）
- `dataSource`: 数据源
- `selectedIndex`: 单列选中的索引
- `selectedIndexes`: 多列选中的索引数组
- `singleResultBlock`: 单列选择结果回调
- `multiResultBlock`: 多列选择结果回调

### ZHHBasePickerView

#### 主要属性

- `titleLabel`: 标题标签
- `cancelButton`: 取消按钮
- `confirmButton`: 确认按钮
- `pickerViewHeight`: 选择器高度
- `pickerHeaderViewHeight`: 头部高度

## 🎯 示例项目

运行示例项目：

```bash
cd Example
pod install
open ZHHPickerView.xcworkspace
```

示例项目包含：

- **基础效果**：展示各种基础样式配置
- **字符串选择器**：单列、多列、联动、行政区划等示例
- **日期选择器**：系统样式和自定义样式的完整示例

## 📄 许可证

ZHHPickerView 基于 MIT 许可证开源。详情请查看 [LICENSE](LICENSE) 文件。

## 👤 作者

桃色三岁, 136769890@qq.com

## 🔗 相关链接

- [GitHub](https://github.com/yue5yueliang/ZHHPickerView)
- [CocoaPods](https://cocoapods.org/pods/ZHHPickerView)
