//
//  ExamplePickerModel.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import Foundation
import ZHHPickerView

/// 首页分组模型
class ExamplePickerModel {
    /// 分组标题
    var title: String = ""
    /// 分组下的选项
    var items: [String] = []
}

/// 日期选择器项模型
class ExampleDatePickerItemModel {
    /// picker 显示文本
    var text: String = ""
    /// 对应的枚举值
    var mode: DatePickerMode = .date
    /// 是否显示上午/下午（仅 ymdH 模式生效）
    var showAMAndPM: Bool = false
}

/// 日期选择器分组模型
class ExampleDatePickerSectionModel {
    /// 分组标题
    var title: String = ""
    /// 分组下的日期项
    var items: [ExampleDatePickerItemModel] = []
}
