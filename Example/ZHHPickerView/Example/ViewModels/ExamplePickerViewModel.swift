//
//  ExamplePickerViewModel.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import Foundation
import ZHHPickerView

/// 首页示例选择器数据
class ExamplePickerViewModel {

    /// 首页示例选择器数据
    lazy var homeSections: [ExamplePickerModel] = {
        var sections: [ExamplePickerModel] = []

        let basic = ExamplePickerModel()
        basic.title = "基础效果"
        basic.items = ["基础效果"]
        sections.append(basic)

        let string = ExamplePickerModel()
        string.title = "字符串选择器"
        string.items = [
            "固定列数选择器",
            "联动选择器",
            "行政区划 - 单层级",
            "行政区划（多级联动 - 含 Code）"
        ]
        sections.append(string)

        let date = ExamplePickerModel()
        date.title = "日期选择器"
        date.items = ["日期系统样式", "日期自定义样式"]
        sections.append(date)

        return sections
    }()

    /// 字符串类型选择器数据
    lazy var stringSections: [ExamplePickerModel] = {
        var sections: [ExamplePickerModel] = []

        let s1 = ExamplePickerModel()
        s1.title = "基础效果"
        s1.items = ["默认效果", "改变按钮样式", "不显示取消按钮，隐藏分割线", "不显示取消按钮，title靠左显示"]
        sections.append(s1)

        let s2 = ExamplePickerModel()
        s2.title = "固定列数选择器"
        s2.items = ["单列选择器", "两列选择器", "三列选择器"]
        sections.append(s2)

        let s3 = ExamplePickerModel()
        s3.title = "联动选择器"
        s3.items = ["两列联动选择器", "三列联动选择器"]
        sections.append(s3)

        let s4 = ExamplePickerModel()
        s4.title = "行政区划 - 单层级"
        s4.items = [
            "省级（省份、直辖市、自治区）",
            "地级（城市）",
            "县级（区县）",
            "乡级（乡镇、街道）",
            "村级（村委会、居委会）"
        ]
        sections.append(s4)

        let s5 = ExamplePickerModel()
        s5.title = "行政区划（多级联动 - 含 Code）"
        s5.items = [
            "\"省份、城市\" 二级联动数据",
            "\"省份、城市、区县\" 三级联动数据",
            "\"省份、城市、区县、乡镇\" 四级联动数据"
        ]
        sections.append(s5)

        return sections
    }()

    /// 日期类型选择器数据
    lazy var dateSections: [ExampleDatePickerSectionModel] = {
        var sections: [ExampleDatePickerSectionModel] = []

        let system = ExampleDatePickerSectionModel()
        system.title = "系统样式"
        system.items = [
            item("年月日（UIDatePickerModeDate）", .date),
            item("年月日 时分（UIDatePickerModeDateAndTime）", .dateAndTime),
            item("时分（UIDatePickerModeTime）", .time),
            item("倒计时（UIDatePickerModeCountDownTimer）", .countDownTimer)
        ]
        sections.append(system)

        let custom = ExampleDatePickerSectionModel()
        custom.title = "自定义样式"
        custom.items = [
            item("年月日 时分秒（yyyy-MM-dd HH:mm:ss）", .ymdHMS),
            item("年月日 时分（yyyy-MM-dd HH:mm）", .ymdHM),
            item("年月日 时（yyyy-MM-dd HH）", .ymdH),
            item("年月日上午下午", .ymdH, showAMAndPM: true),
            item("月日 时分（MM-dd HH:mm）", .mdHM),
            item("年月日（yyyy-MM-dd）", .ymd),
            item("年月（yyyy-MM）", .ym),
            item("年（yyyy）", .y),
            item("月日（MM-dd）", .md),
            item("时分秒（HH:mm:ss）", .hMS),
            item("时分（HH:mm）", .hM),
            item("分秒（mm:ss）", .mS)
        ]
        sections.append(custom)

        return sections
    }()

    private func item(_ text: String, _ mode: DatePickerMode, showAMAndPM: Bool = false) -> ExampleDatePickerItemModel {
        let m = ExampleDatePickerItemModel()
        m.text = text
        m.mode = mode
        m.showAMAndPM = showAMAndPM
        return m
    }
}
