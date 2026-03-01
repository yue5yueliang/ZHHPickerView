//
//  DatePickerView.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 日期选择器模式
public enum DatePickerMode: Int {
    case date           // 日期（系统样式）
    case dateAndTime    // 日期+时间（系统样式）
    case time           // 时间（系统样式）
    case countDownTimer // 倒计时（系统样式）
    case ymdHMS         // 年月日 时分秒
    case ymdHM          // 年月日 时分
    case ymdH           // 年月日 时
    case mdHM           // 月日 时分
    case ymd            // 年月日
    case ym             // 年月
    case y              // 年
    case md             // 月日
    case hMS            // 时分秒
    case hM             // 时分
    case mS             // 分秒
}

/// 日期单位显示类型（年/月/日等文字）
public enum DateUnitDisplayType: Int {
    case all         // 每列都显示单位
    case onlyCenter  // 仅中间列显示单位
    case none        // 不显示单位
}

/// 日期选择器
open class DatePickerView: BasePickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - 基础配置

    /// 日期选择器显示类型
    public var pickerMode: DatePickerMode = .date
    /// 当前选中的日期值（建议使用 selectedDate）
    public var selectedDate: Date?
    /// 当前选中的日期字符串
    public var selectedValue: String?
    /// 最小日期
    public var minDate: Date?
    /// 最大日期
    public var maxDate: Date?
    /// 是否自动选择，即滚动选择器后立即执行结果回调，默认 NO
    public var isAutoSelect: Bool = false
    /// 选择结果回调
    public var resultBlock: ((Date?, String?) -> Void)?
    /// 滚动时触发的回调
    public var changeBlock: ((Date?, String?) -> Void)?

    // MARK: - 显示配置

    /// 日期单位显示类型
    public var unitDisplayType: DateUnitDisplayType = .all
    /// 是否显示“星期”，默认 NO
    public var showWeek: Bool = false
    /// 是否显示“今天”，默认 NO
    public var showToday: Bool = false
    /// 是否显示“至今”，默认 NO
    public var showToNow: Bool = false
    /// 首行自定义内容，配合 selectValue 设置默认选中
    public var firstRowContent: String?
    /// 末行自定义内容，配合 selectValue 设置默认选中
    public var lastRowContent: String?
    /// 日期数据排序是否降序，默认为 NO（升序）
    public var descending: Bool = false
    /// 是否显示前导零（如：2020-01-01），默认为 NO
    public var showLeadingZero: Bool = false
    /// 是否使用 12 小时制，默认为 NO
    public var twelveHourMode: Bool = false
    /// 分钟的间隔，默认 1（范围 1~30）
    public var minuteInterval: Int = 1
    /// 秒数的间隔，默认 1（范围 1~30）
    public var secondInterval: Int = 1
    /// 倒计时时长（仅适用于倒计时模式）
    public var countDownDuration: TimeInterval = 0
    /// 自定义月份数据源（如：@["1月", "2月", ...]）
    public var monthNames: [String]?
    /// 是否使用国际化环境下的月份简称（如 "Jan" 而非 "January"）
    public var useShortMonthNames: Bool = false
    /// 自定义日期单位显示（格式：@["year": "年", "month": "月", ...]）
    public var customUnit: [String: String]?
    /// 是否显示上午/下午，默认 NO：仅对 YMDH 模式生效
    public var showAMAndPM: Bool = false
    /// 自定义时区，默认为当前时区
    public var timeZone: TimeZone? {
        didSet { if let tz = timeZone { Date.zhhSetTimeZone(tz) } }
    }
    /// 设置日历对象（可指定农历等）
    public var calendar: Calendar?
    /// 指定不允许选择的日期列表
    public var nonSelectableDates: [Date]?
    /// 当选择到不允许的日期时触发的回调
    public var didSelectNonSelectableDateBlock: ((Date?, String?) -> Void)?

    // MARK: - 样式配置

    /// 设置 picker 的行高，默认为 40
    public var pickerRowHeight: CGFloat = 40
    /// 设置 picker 的列宽
    public var columnWidth: CGFloat = 0
    /// 设置 picker 文本的颜色，默认为 labelColor
    public var pickerTextColor: UIColor? = .label
    /// 设置 picker 文本的字体，默认为 22pt
    public var pickerTextFont: UIFont? = .systemFont(ofSize: 22)
    /// 设置 picker 选中行文本的颜色
    public var pickerSelectedTextColor: UIColor?
    /// 设置 picker 选中行文本的字体
    public var pickerSelectedTextFont: UIFont?
    /// 设置 picker 文本支持的最大行数，默认为 2
    public var maxTextLines: Int = 2
    /// 日期单位文本颜色（仅居中单位样式生效）
    public var dateUnitTextColor: UIColor?
    /// 日期单位文本字体（仅居中单位样式生效）
    public var dateUnitTextFont: UIFont?
    /// 日期单位 Label 的水平偏移量
    public var dateUnitOffsetX: CGFloat = 0
    /// 日期单位 Label 的垂直偏移量
    public var dateUnitOffsetY: CGFloat = 0
    /// 设置语言（如：zh-Hans、zh-Hant、en；nil 时跟随系统）
    public var language: String? = "zh-Hans"

    /// 当前选择器是否正在滚动（可用于避免滚动未停止时点击“确定”导致数据异常）
    public var isRolling: Bool {
        if useSystemPicker { return isAnyScrollRolling(in: datePicker) }
        return isAnyScrollRolling(in: pickerView)
    }

    // MARK: - 私有属性

    /// 是否使用系统 UIDatePicker（系统样式）
    private var useSystemPicker: Bool = false
    /// 系统样式的日期选择器（UIDatePicker）
    private var datePicker = UIDatePicker()
    /// 自定义样式的日期选择器（UIPickerView）
    private var pickerView = UIPickerView()
    /// 日期格式字符串，用于格式化显示
    private var dateFormat: String = ""
    /// 日期单位数组，如 @["年", "月", "日"]
    private var unitArr: [String] = []
    /// 年份数据数组
    private var yearArr: [String] = []
    /// 月份数据数组
    private var monthArr: [String]?
    /// 日期数据数组
    private var dayArr: [String]?
    /// 小时数据数组
    private var hourArr: [String]?
    /// 分钟数据数组
    private var minuteArr: [String]?
    /// 秒钟数据数组
    private var secondArr: [String]?
    /// 月周数组（用于年月周模式）
    private var monthWeekArr: [String]?
    /// 年周数组（用于年周模式）
    private var yearWeekArr: [String]?
    /// 季度数组（用于年季度模式）
    private var quarterArr: [String]?
    /// 当前选中的各组件索引
    private var yearIndex = 0, monthIndex = 0, dayIndex = 0
    private var hourIndex = 0, minuteIndex = 0, secondIndex = 0
    private var monthWeekIndex = 0, yearWeekIndex = 0, quarterIndex = 0
    /// 当前选择的日期值
    private var mSelectedDate: Date?
    /// 当前选择的日期字符串（格式化后的值）
    private var mSelectedValue: String = ""
    /// 当前正在滚动的组件索引（用于快速点击确定时获取最新选中行）
    private var rollingComponent = 0, rollingRow = 0

    /// 初始化日期选择器
    /// - Parameter pickerMode: 日期选择器显示类型
    public init(pickerMode: DatePickerMode) {
        super.init()
        self.pickerMode = pickerMode
        pickerTextFont = .systemFont(ofSize: 22)
        pickerTextColor = .label
        maxTextLines = 2
        pickerRowHeight = 40
        language = "zh-Hans"
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func show() {
        setupDateFormatter()
        if useSystemPicker {
            contentView.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            let bottom: CGFloat = safeAreaInsets.bottom > 0 ? -safeAreaInsets.bottom : 0
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: pickerHeaderView.bottomAnchor),
                datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: bottom),
                datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
            datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        } else {
            contentView.addSubview(pickerView)
            pickerView.translatesAutoresizingMaskIntoConstraints = false
            let bottom: CGFloat = safeAreaInsets.bottom > 0 ? -safeAreaInsets.bottom : 0
            NSLayoutConstraint.activate([
                pickerView.topAnchor.constraint(equalTo: pickerHeaderView.bottomAnchor),
                pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: bottom),
                pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.backgroundColor = .clear
        }
        reloadData()
        super.show()
    }

    public override func handleConfirmAction() {
        if isRolling {
            pickerView(pickerView, didSelectRow: rollingRow, inComponent: rollingComponent)
        }
        resultBlock?(mSelectedDate, mSelectedValue)
        super.handleConfirmAction()
    }

    // MARK: - 初始化

    /// 根据 pickerMode 设置日期格式和选择器样式（系统/自定义）
    private func setupDateFormatter() {
        switch pickerMode {
        case .date:
            dateFormat = "yyyy-MM-dd"
            useSystemPicker = true
            datePicker.datePickerMode = .date
        case .dateAndTime:
            dateFormat = "yyyy-MM-dd HH:mm"
            useSystemPicker = true
            datePicker.datePickerMode = .dateAndTime
        case .time:
            dateFormat = "HH:mm"
            useSystemPicker = true
            datePicker.datePickerMode = .time
        case .countDownTimer:
            dateFormat = "HH:mm"
            useSystemPicker = true
            datePicker.datePickerMode = .countDownTimer
        case .ymdHMS:
            dateFormat = "yyyy-MM-dd HH:mm:ss"
            useSystemPicker = false
            unitArr = [yearUnit, monthUnit, dayUnit, hourUnit, minuteUnit, secondUnit]
        case .ymdHM:
            dateFormat = "yyyy-MM-dd HH:mm"
            useSystemPicker = false
            unitArr = [yearUnit, monthUnit, dayUnit, hourUnit, minuteUnit]
        case .ymdH:
            dateFormat = "yyyy-MM-dd HH"
            useSystemPicker = false
            unitArr = [yearUnit, monthUnit, dayUnit, showAMAndPM ? "" : hourUnit]
        case .mdHM:
            dateFormat = "MM-dd HH:mm"
            useSystemPicker = false
            unitArr = [monthUnit, dayUnit, hourUnit, minuteUnit]
        case .ymd:
            dateFormat = "yyyy-MM-dd"
            useSystemPicker = false
            unitArr = [yearUnit, monthUnit, dayUnit]
        case .ym:
            dateFormat = "yyyy-MM"
            useSystemPicker = false
            unitArr = [yearUnit, monthUnit]
        case .y:
            dateFormat = "yyyy"
            useSystemPicker = false
            unitArr = [yearUnit]
        case .md:
            dateFormat = "MM-dd"
            useSystemPicker = false
            unitArr = [monthUnit, dayUnit]
        case .hMS:
            dateFormat = "HH:mm:ss"
            useSystemPicker = false
            unitArr = [hourUnit, minuteUnit, secondUnit]
        case .hM:
            dateFormat = "HH:mm"
            useSystemPicker = false
            unitArr = [hourUnit, minuteUnit]
        case .mS:
            dateFormat = "mm:ss"
            useSystemPicker = false
            unitArr = [minuteUnit, secondUnit]
        }
    }

    /// 配置选择器数据和默认选中状态
    private func configurePickerData() {
        let min = handlerMinDate(minDate)
        let max = handlerMaxDate(maxDate)
        minDate = min
        maxDate = max

        if zhhCompare(min, target: max, format: dateFormat) == .orderedDescending {
            minDate = .distantPast
            maxDate = .distantFuture
        }

        mSelectedDate = handlerSelectedDate(selectedDate, format: dateFormat)
        if useSystemPicker {
            datePicker.minimumDate = minDate
            datePicker.maximumDate = maxDate
            datePicker.locale = Locale(identifier: language ?? "zh-Hans")
            if let tz = timeZone { datePicker.timeZone = tz }
            if let cal = calendar { datePicker.calendar = cal }
            if pickerMode == .countDownTimer && countDownDuration > 0 {
                datePicker.countDownDuration = countDownDuration
            }
            if minuteInterval > 1 { datePicker.minuteInterval = minuteInterval }
            if let d = mSelectedDate { datePicker.date = d }
            mSelectedValue = Date.zhhStringFromDate(mSelectedDate ?? Date(), format: dateFormat, language: language)
        } else {
            setupDateArrays()
        }
    }

    /// 根据 pickerMode 设置日期数据源数组（年/月/日/时/分/秒等）
    private func setupDateArrays() {
        let base = mSelectedDate ?? Date()
        let min = minDate ?? .distantPast
        let max = maxDate ?? .distantFuture

        yearArr = yearArray(min: min.zhhYear, max: max.zhhYear)
        if [.ymdHMS, .ymdHM, .ymdH, .ymd, .ym, .y, .mdHM, .md].contains(pickerMode) {
            monthArr = monthArray(year: base.zhhYear, minDate: min, maxDate: max)
        }
        if [.ymdHMS, .ymdHM, .ymdH, .ymd, .mdHM, .md].contains(pickerMode) {
            dayArr = dayArray(year: base.zhhYear, month: base.zhhMonth, minDate: min, maxDate: max)
        }
        if [.ymdHMS, .ymdHM, .ymdH, .mdHM, .hMS, .hM].contains(pickerMode) {
            hourArr = hourArray(year: base.zhhYear, month: base.zhhMonth, day: base.zhhDay, minDate: min, maxDate: max)
        }
        if [.ymdHMS, .ymdHM, .mdHM, .hMS, .hM, .mS].contains(pickerMode) {
            minuteArr = minuteArray(year: base.zhhYear, month: base.zhhMonth, day: base.zhhDay, hour: base.zhhHour, minDate: min, maxDate: max)
        }
        if [.ymdHMS, .hMS, .mS].contains(pickerMode) {
            secondArr = secondArray(year: base.zhhYear, month: base.zhhMonth, day: base.zhhDay, hour: base.zhhHour, minute: base.zhhMinute, minDate: min, maxDate: max)
        }
    }

    private func handlerMinDate(_ d: Date?) -> Date {
        var r = d ?? .distantPast
        if twelveHourMode {
            var c = Date.zhhCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: r)
            c.hour = 1
            r = Date.zhhCalendar.date(from: c) ?? r
        }
        return r
    }

    private func handlerMaxDate(_ d: Date?) -> Date {
        var r = d ?? .distantFuture
        if twelveHourMode {
            var c = Date.zhhCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: r)
            c.hour = 12
            r = Date.zhhCalendar.date(from: c) ?? r
        }
        return r
    }

    private func handlerSelectedDate(_ d: Date?, format: String) -> Date {
        var r = d ?? Date()
        if let v = selectedValue, !v.isEmpty {
            if v == lastRowContent { return showToNow ? Date() : r }
            if v == firstRowContent { return r }
            if let parsed = Date.zhhDateFromString(v, format: format, language: language) {
                r = parsed
            }
        }
        let min = minDate ?? .distantPast
        let max = maxDate ?? .distantFuture
        // mdHM/md 格式不含年，与 distantPast/distantFuture 比较无意义，不 clamp
        if ![.mdHM, .md].contains(pickerMode) || (min != .distantPast || max != .distantFuture) {
            if zhhCompare(r, target: min, format: format) == .orderedAscending { r = min }
            if zhhCompare(r, target: max, format: format) == .orderedDescending { r = max }
        }
        return r
    }

    private func zhhCompare(_ a: Date, target b: Date, format: String) -> ComparisonResult {
        let s1 = Date.zhhStringFromDate(a, format: format, language: language)
        let s2 = Date.zhhStringFromDate(b, format: format, language: language)
        let d1 = Date.zhhDateFromString(s1, format: format, language: language) ?? a
        let d2 = Date.zhhDateFromString(s2, format: format, language: language) ?? b
        return d1.compare(d2)
    }

    private func yearArray(min: Int, max: Int) -> [String] {
        var arr = (min...max).map { stringWithYear($0) }
        if descending { arr.reverse() }
        if let first = firstRowContent { arr.insert(first, at: 0) }
        if let last = lastRowContent { arr.append(last) }
        return arr
    }

    private func monthArray(year: Int, minDate: Date, maxDate: Date) -> [String] {
        var start = 1, end = 12
        if ![.mdHM, .md].contains(pickerMode) {
            if year == minDate.zhhYear { start = minDate.zhhMonth }
            if year == maxDate.zhhYear { end = maxDate.zhhMonth }
        }
        var arr = (start...end).map { stringWithNumber($0) }
        if descending { arr.reverse() }
        return arr
    }

    private func dayArray(year: Int, month: Int, minDate: Date, maxDate: Date) -> [String] {
        let days = Date.zhhGetDaysInYear(year, month: month)
        var start = 1, end = days
        if ![.mdHM, .md].contains(pickerMode) {
            if year == minDate.zhhYear && month == minDate.zhhMonth { start = minDate.zhhDay }
            if year == maxDate.zhhYear && month == maxDate.zhhMonth { end = maxDate.zhhDay }
        }
        var arr = (start...end).map { stringWithNumber($0) }
        if descending { arr.reverse() }
        return arr
    }

    private func hourArray(year: Int, month: Int, day: Int, minDate: Date, maxDate: Date) -> [String] {
        if pickerMode == .ymdH && showAMAndPM {
            return [Bundle.zhhLocalizedString(key: "上午", language: language),
                    Bundle.zhhLocalizedString(key: "下午", language: language)]
        }
        var start = twelveHourMode ? 1 : 0
        var end = twelveHourMode ? 12 : 23
        if pickerMode != .mdHM {
            if year == minDate.zhhYear && month == minDate.zhhMonth && day == minDate.zhhDay { start = Swift.max(start, minDate.zhhHour) }
            if year == maxDate.zhhYear && month == maxDate.zhhMonth && day == maxDate.zhhDay { end = Swift.min(end, maxDate.zhhHour) }
        }
        var arr = (start...end).map { stringWithNumber($0) }
        if descending { arr.reverse() }
        return arr
    }

    private func minuteArray(year: Int, month: Int, day: Int, hour: Int, minDate: Date, maxDate: Date) -> [String] {
        var start = 0, end = 59
        if pickerMode != .mdHM {
            if year == minDate.zhhYear && month == minDate.zhhMonth && day == minDate.zhhDay && hour == minDate.zhhHour { start = minDate.zhhMinute }
            if year == maxDate.zhhYear && month == maxDate.zhhMonth && day == maxDate.zhhDay && hour == maxDate.zhhHour { end = maxDate.zhhMinute }
        }
        var arr = stride(from: start, through: end, by: minuteInterval).map { stringWithNumber($0) }
        if descending { arr.reverse() }
        return arr
    }

    private func secondArray(year: Int, month: Int, day: Int, hour: Int, minute: Int, minDate: Date, maxDate: Date) -> [String] {
        var start = 0, end = 59
        if year == minDate.zhhYear && month == minDate.zhhMonth && day == minDate.zhhDay && hour == minDate.zhhHour && minute == minDate.zhhMinute { start = minDate.zhhSecond }
        if year == maxDate.zhhYear && month == maxDate.zhhMonth && day == maxDate.zhhDay && hour == maxDate.zhhHour && minute == maxDate.zhhMinute { end = maxDate.zhhSecond }
        var arr = stride(from: start, through: end, by: secondInterval).map { stringWithNumber($0) }
        if descending { arr.reverse() }
        return arr
    }

    private func stringWithYear(_ y: Int) -> String {
        showLeadingZero ? String(format: "%04d", y) : "\(y)"
    }

    private func stringWithNumber(_ n: Int) -> String {
        showLeadingZero ? String(format: "%02d", n) : "\(n)"
    }

    private var yearUnit: String { customUnit?["year"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "年", language: language) : "") }
    private var monthUnit: String { customUnit?["month"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "月", language: language) : "") }
    private var dayUnit: String { customUnit?["day"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "日", language: language) : "") }
    private var hourUnit: String { customUnit?["hour"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "时", language: language) : "") }
    private var minuteUnit: String { customUnit?["minute"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "分", language: language) : "") }
    private var secondUnit: String { customUnit?["second"] ?? (language?.hasPrefix("zh") == true ? Bundle.zhhLocalizedString(key: "秒", language: language) : "") }

    // MARK: - 选择器视图

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerMode {
        case .ymdHMS: return 6
        case .ymdHM: return 5
        case .ymdH, .mdHM: return 4
        case .ymd, .hMS: return 3
        case .ym, .md, .hM, .mS: return 2
        case .y: return 1
        default: return 0
        }
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rows = componentRows()
        guard component < rows.count else { return 0 }
        return max(0, rows[component])
    }

    private func componentRows() -> [Int] {
        switch pickerMode {
        case .ymdHMS: return [yearArr.count, monthArr?.count ?? 0, dayArr?.count ?? 0, hourArr?.count ?? 0, minuteArr?.count ?? 0, secondArr?.count ?? 0]
        case .ymdHM: return [yearArr.count, monthArr?.count ?? 0, dayArr?.count ?? 0, hourArr?.count ?? 0, minuteArr?.count ?? 0]
        case .ymdH: return [yearArr.count, monthArr?.count ?? 0, dayArr?.count ?? 0, hourArr?.count ?? 0]
        case .mdHM: return [monthArr?.count ?? 0, dayArr?.count ?? 0, hourArr?.count ?? 0, minuteArr?.count ?? 0]
        case .ymd: return [yearArr.count, monthArr?.count ?? 0, dayArr?.count ?? 0]
        case .ym: return [yearArr.count, monthArr?.count ?? 0]
        case .y: return [yearArr.count]
        case .md: return [monthArr?.count ?? 0, dayArr?.count ?? 0]
        case .hMS: return [hourArr?.count ?? 0, minuteArr?.count ?? 0, secondArr?.count ?? 0]
        case .hM: return [hourArr?.count ?? 0, minuteArr?.count ?? 0]
        case .mS: return [minuteArr?.count ?? 0, secondArr?.count ?? 0]
        default: return []
        }
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        pickerRowHeight
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let n = numberOfComponents(in: pickerView)
        let delta: CGFloat = n > 3 ? 5 : 10
        let w = pickerView.bounds.width / CGFloat(n) - delta
        if columnWidth > 0 && columnWidth <= w { return columnWidth }
        return w
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? {
            let l = UILabel()
            l.backgroundColor = .clear
            l.textAlignment = .center
            l.font = pickerTextFont
            l.textColor = pickerTextColor ?? .label
            l.numberOfLines = maxTextLines
            l.adjustsFontSizeToFitWidth = true
            l.minimumScaleFactor = 0.5
            return l
        }()
        rollingComponent = component
        rollingRow = pickerView.selectedRow(inComponent: component)
        if rollingRow < 0 { rollingRow = 0 }
        label.text = titleForRow(row, component: component)
        return label
    }

    private func titleForRow(_ row: Int, component: Int) -> String {
        let sel = selectorForMode()
        guard component < sel.count else { return "" }
        let type = sel[component]
        let unit = unitDisplayType == .all ? (component < unitArr.count ? unitArr[component] : "") : ""
        switch type {
        case "year":
            guard row < yearArr.count else { return "0" }
            let s = yearArr[row]
            if s == lastRowContent || s == firstRowContent { return s }
            return s + unit
        case "month":
            guard let arr = monthArr, row < arr.count else { return "0" }
            var s = arr[row]
            if let names = monthNames, let m = Int(s), m >= 1, m <= 12, m - 1 < names.count { s = names[m - 1] }
            else if language?.hasPrefix("zh") != true, let m = Int(s), m >= 1, m <= 12 {
                let fmt = DateFormatter()
                fmt.locale = Locale(identifier: language ?? "en")
                s = useShortMonthNames ? fmt.shortMonthSymbols[m - 1] : fmt.monthSymbols[m - 1]
            } else { s = s + unit }
            return s
        case "day":
            guard let arr = dayArr, row < arr.count else { return "0" }
            let s = arr[row]
            if showToday, let sel = mSelectedDate, sel.zhhYear == Date().zhhYear, sel.zhhMonth == Date().zhhMonth, Int(s) == Date().zhhDay {
                return Bundle.zhhLocalizedString(key: "今天", language: language)
            }
            return s + unit
        case "hour":
            guard let arr = hourArr, row < arr.count else { return "0" }
            let s = arr[row]
            if s == lastRowContent || s == firstRowContent { return s }
            return s + unit
        case "minute": fallthrough
        case "second":
            let arr = type == "minute" ? minuteArr : secondArr
            guard let a = arr, row < a.count else { return "0" }
            return a[row] + unit
        default: return ""
        }
    }

    private func selectorForMode() -> [String] {
        switch pickerMode {
        case .ymdHMS: return ["year", "month", "day", "hour", "minute", "second"]
        case .ymdHM: return ["year", "month", "day", "hour", "minute"]
        case .ymdH: return ["year", "month", "day", "hour"]
        case .mdHM: return ["month", "day", "hour", "minute"]
        case .ymd: return ["year", "month", "day"]
        case .ym: return ["year", "month"]
        case .y: return ["year"]
        case .md: return ["month", "day"]
        case .hMS: return ["hour", "minute", "second"]
        case .hM: return ["hour", "minute"]
        case .mS: return ["minute", "second"]
        default: return []
        }
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateIndexes(component: component, row: row)
        updateSelectedFromComponents()
        if let block = changeBlock { block(mSelectedDate, mSelectedValue) }
        if isAutoSelect, let block = resultBlock { block(mSelectedDate, mSelectedValue) }
    }

    private func updateIndexes(component: Int, row: Int) {
        switch pickerMode {
        case .ymdHMS:
            switch component {
            case 0: yearIndex = row; reloadDateArrays(month: true, day: true, hour: true, minute: true, second: true)
            case 1: monthIndex = row; reloadDateArrays(month: false, day: true, hour: true, minute: true, second: true)
            case 2: dayIndex = row; reloadDateArrays(month: false, day: false, hour: true, minute: true, second: true)
            case 3: hourIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: true, second: true)
            case 4: minuteIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: false, second: true)
            case 5: secondIndex = row
            default: break
            }
        case .ymdHM:
            switch component {
            case 0: yearIndex = row; reloadDateArrays(month: true, day: true, hour: true, minute: true, second: false)
            case 1: monthIndex = row; reloadDateArrays(month: false, day: true, hour: true, minute: true, second: false)
            case 2: dayIndex = row; reloadDateArrays(month: false, day: false, hour: true, minute: true, second: false)
            case 3: hourIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: true, second: false)
            case 4: minuteIndex = row
            default: break
            }
        case .ymdH:
            switch component {
            case 0: yearIndex = row; reloadDateArrays(month: true, day: true, hour: true, minute: false, second: false)
            case 1: monthIndex = row; reloadDateArrays(month: false, day: true, hour: true, minute: false, second: false)
            case 2: dayIndex = row; reloadDateArrays(month: false, day: false, hour: true, minute: false, second: false)
            case 3: hourIndex = row
            default: break
            }
        case .mdHM:
            switch component {
            case 0: monthIndex = row; reloadDateArrays(month: false, day: true, hour: true, minute: true, second: false)
            case 1: dayIndex = row; reloadDateArrays(month: false, day: false, hour: true, minute: true, second: false)
            case 2: hourIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: true, second: false)
            case 3: minuteIndex = row
            default: break
            }
        case .ymd:
            switch component {
            case 0: yearIndex = row; reloadDateArrays(month: true, day: true, hour: false, minute: false, second: false)
            case 1: monthIndex = row; reloadDateArrays(month: false, day: true, hour: false, minute: false, second: false)
            case 2: dayIndex = row
            default: break
            }
        case .ym:
            switch component {
            case 0: yearIndex = row; reloadDateArrays(month: true, day: false, hour: false, minute: false, second: false)
            case 1: monthIndex = row
            default: break
            }
        case .y: yearIndex = row
        case .md:
            switch component {
            case 0: monthIndex = row; reloadDateArrays(month: false, day: true, hour: false, minute: false, second: false)
            case 1: dayIndex = row
            default: break
            }
        case .hMS:
            switch component {
            case 0: hourIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: true, second: true)
            case 1: minuteIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: false, second: true)
            case 2: secondIndex = row
            default: break
            }
        case .hM:
            switch component {
            case 0: hourIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: true, second: false)
            case 1: minuteIndex = row
            default: break
            }
        case .mS:
            switch component {
            case 0: minuteIndex = row; reloadDateArrays(month: false, day: false, hour: false, minute: false, second: true)
            case 1: secondIndex = row
            default: break
            }
        default: break
        }
    }

    private func reloadDateArrays(month: Bool, day: Bool, hour: Bool, minute: Bool, second: Bool) {
        let base = mSelectedDate ?? Date()
        let min = minDate ?? .distantPast
        let max = maxDate ?? .distantFuture
        let yStr = [.mdHM, .md].contains(pickerMode) ? "\(base.zhhYear)" : (yearArr[safe: yearIndex] ?? "0")
        let mStr = monthArr?[safe: monthIndex] ?? "0"
        if month && !yearArr.isEmpty {
            if let y = Int(yStr), y > 0, yStr != lastRowContent, yStr != firstRowContent {
                monthArr = monthArray(year: y, minDate: min, maxDate: max)
                pickerView.reloadComponent(1)
            }
        }
        if day && (monthArr?.isEmpty != true) {
            if let y = Int(yStr), let m = Int(mStr), y > 0, m > 0 {
                dayArr = dayArray(year: y, month: m, minDate: min, maxDate: max)
                if pickerMode == .ymdHMS || pickerMode == .ymdHM { pickerView.reloadComponent(2) }
                else if pickerMode == .ymd { pickerView.reloadComponent(2) }
                else if pickerMode == .md { pickerView.reloadComponent(1) }
            }
        }
        if hour && (dayArr?.isEmpty != true) {
            let dStr = dayArr?[safe: dayIndex] ?? "0"
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr), y > 0 || pickerMode == .hMS || pickerMode == .hM {
                let yy = [.hMS, .hM].contains(pickerMode) ? base.zhhYear : y
                let mm = [.hMS, .hM].contains(pickerMode) ? base.zhhMonth : m
                let dd = [.hMS, .hM].contains(pickerMode) ? base.zhhDay : d
                hourArr = hourArray(year: yy, month: mm, day: dd, minDate: min, maxDate: max)
                if pickerMode == .ymdHMS { pickerView.reloadComponent(3) }
                else if pickerMode == .ymdHM { pickerView.reloadComponent(3) }
                else if pickerMode == .ymdH { pickerView.reloadComponent(3) }
                else if pickerMode == .mdHM { pickerView.reloadComponent(2) }
                else if pickerMode == .hMS || pickerMode == .hM { pickerView.reloadComponent(1) }
            }
        }
        if minute && (hourArr?.isEmpty != true) {
            let hStr = hourArr?[safe: hourIndex] ?? "0"
            if hStr != lastRowContent, hStr != firstRowContent, let h = Int(hStr) {
                let yy = [.hMS, .hM].contains(pickerMode) ? base.zhhYear : Int(yStr) ?? 0
                let mm = [.hMS, .hM].contains(pickerMode) ? base.zhhMonth : Int(mStr) ?? 0
                let dd = [.hMS, .hM].contains(pickerMode) ? base.zhhDay : Int(dayArr?[safe: dayIndex] ?? "0") ?? 0
                minuteArr = minuteArray(year: yy, month: mm, day: dd, hour: h, minDate: min, maxDate: max)
                if pickerMode == .ymdHMS { pickerView.reloadComponent(4) }
                else if pickerMode == .ymdHM { pickerView.reloadComponent(4) }
                else if pickerMode == .mdHM { pickerView.reloadComponent(3) }
                else if pickerMode == .hMS { pickerView.reloadComponent(2) }
                else if pickerMode == .mS { pickerView.reloadComponent(1) }
            }
        }
        if second && (minuteArr?.isEmpty != true) {
            let minStr = minuteArr?[safe: minuteIndex] ?? "0"
            if minStr != lastRowContent, minStr != firstRowContent, let mn = Int(minStr) {
                let h = Int(hourArr?[safe: hourIndex] ?? "0") ?? 0
                secondArr = secondArray(year: base.zhhYear, month: base.zhhMonth, day: base.zhhDay, hour: h, minute: mn, minDate: min, maxDate: max)
                if pickerMode == .ymdHMS { pickerView.reloadComponent(5) }
                else if pickerMode == .hMS { pickerView.reloadComponent(2) }
                else if pickerMode == .mS { pickerView.reloadComponent(1) }
            }
        }
    }

    private func updateSelectedFromComponents() {
        let yStr = yearArr[safe: yearIndex] ?? "0"
        let mStr = monthArr?[safe: monthIndex] ?? "0"
        let dStr = dayArr?[safe: dayIndex] ?? "0"
        let hStr = hourArr?[safe: hourIndex] ?? "0"
        let minStr = minuteArr?[safe: minuteIndex] ?? "0"
        let sStr = secondArr?[safe: secondIndex] ?? "0"

        if yStr == lastRowContent || yStr == firstRowContent || mStr == lastRowContent || mStr == firstRowContent {
            mSelectedDate = showToNow ? Date() : nil
            mSelectedValue = yStr == lastRowContent || mStr == lastRowContent ? (lastRowContent ?? "") : (firstRowContent ?? "")
            return
        }

        switch pickerMode {
        case .ymdHMS:
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr), let h = Int(hStr), let mn = Int(minStr), let s = Int(sStr) {
                mSelectedDate = Date.zhhSetYear(y, month: m, day: d, hour: h, minute: mn, second: s)
                mSelectedValue = String(format: "%04d-%02d-%02d %02d:%02d:%02d", y, m, d, h, mn, s)
            }
        case .ymdHM:
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr), let h = Int(hStr), let mn = Int(minStr) {
                mSelectedDate = Date.zhhSetYear(y, month: m, day: d, hour: h, minute: mn)
                mSelectedValue = String(format: "%04d-%02d-%02d %02d:%02d", y, m, d, h, mn)
            }
        case .ymd:
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr) {
                mSelectedDate = Date.zhhSetYear(y, month: m, day: d)
                mSelectedValue = String(format: "%04d-%02d-%02d", y, m, d)
            }
        case .ym:
            if let y = Int(yStr), let m = Int(mStr) {
                mSelectedDate = Date.zhhSetYear(y, month: m)
                mSelectedValue = String(format: "%04d-%02d", y, m)
            }
        case .y:
            if let y = Int(yStr) {
                mSelectedDate = Date.zhhSetYear(y)
                mSelectedValue = String(format: "%04d", y)
            }
        case .md:
            if let m = Int(mStr), let d = Int(dStr) {
                mSelectedDate = Date.zhhSetMonth(m, day: d)
                mSelectedValue = String(format: "%02d-%02d", m, d)
            }
        case .hMS:
            if let h = Int(hStr), let mn = Int(minStr), let s = Int(sStr) {
                mSelectedDate = Date.zhhSetHour(h, minute: mn, second: s)
                mSelectedValue = String(format: "%02d:%02d:%02d", h, mn, s)
            }
        case .hM:
            if let h = Int(hStr), let mn = Int(minStr) {
                mSelectedDate = Date.zhhSetHour(h, minute: mn)
                mSelectedValue = String(format: "%02d:%02d", h, mn)
            }
        case .mS:
            if let mn = Int(minStr), let s = Int(sStr) {
                mSelectedDate = Date.zhhSetMinute(mn, second: s)
                mSelectedValue = String(format: "%02d:%02d", mn, s)
            }
        case .ymdH:
            if let y = Int(yStr), let m = Int(mStr), let d = Int(dStr) {
                var h = Int(hStr) ?? 0
                if showAMAndPM { h = hourIndex == 0 ? 0 : 12 }
                mSelectedDate = Date.zhhSetYear(y, month: m, day: d, hour: h)
                mSelectedValue = showAMAndPM ? String(format: "%04d-%02d-%02d %@", y, m, d, hStr) : String(format: "%04d-%02d-%02d %02d", y, m, d, h)
            }
        case .mdHM:
            if let m = Int(mStr), let d = Int(dStr), let h = Int(hStr), let mn = Int(minStr) {
                let y = (mSelectedDate ?? Date()).zhhYear
                mSelectedDate = Date.zhhSetYear(y, month: m, day: d, hour: h, minute: mn)
                mSelectedValue = String(format: "%02d-%02d %02d:%02d", m, d, h, mn)
            }
        default: break
        }
    }

    /// 配置数据并刷新选择器，滚动到选中位置
    private func reloadData() {
        configurePickerData()
        if useSystemPicker {
            if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .wheels }
        } else {
            pickerView.reloadAllComponents()
            scrollToSelectDate(mSelectedDate, animated: false)
            updateSelectedFromComponents()
        }
    }

    /// 滚动到指定日期的位置
    /// - Parameters:
    ///   - date: 要滚动到的日期
    ///   - animated: 是否使用动画
    private func scrollToSelectDate(_ date: Date?, animated: Bool) {
        guard let d = date else { return }
        yearIndex = yearArr.firstIndex(of: stringWithYear(d.zhhYear)) ?? 0
        monthIndex = monthArr?.firstIndex(of: stringWithNumber(d.zhhMonth)) ?? 0
        dayIndex = dayArr?.firstIndex(of: stringWithNumber(d.zhhDay)) ?? 0
        hourIndex = hourArr?.firstIndex(of: stringWithNumber(d.zhhHour)) ?? 0
        minuteIndex = minuteArr?.firstIndex(of: stringWithNumber(d.zhhMinute)) ?? 0
        secondIndex = secondArr?.firstIndex(of: stringWithNumber(d.zhhSecond)) ?? 0
        if pickerMode == .ymdH && showAMAndPM { hourIndex = d.zhhHour < 12 ? 0 : 1 }

        let rows = componentRows()
        let indices: [Int]
        switch pickerMode {
        case .ymdHMS: indices = [yearIndex, monthIndex, dayIndex, hourIndex, minuteIndex, secondIndex]
        case .ymdHM: indices = [yearIndex, monthIndex, dayIndex, hourIndex, minuteIndex]
        case .ymdH: indices = [yearIndex, monthIndex, dayIndex, hourIndex]
        case .mdHM: indices = [monthIndex, dayIndex, hourIndex, minuteIndex]
        case .ymd: indices = [yearIndex, monthIndex, dayIndex]
        case .ym: indices = [yearIndex, monthIndex]
        case .y: indices = [yearIndex]
        case .md: indices = [monthIndex, dayIndex]
        case .hMS: indices = [hourIndex, minuteIndex, secondIndex]
        case .hM: indices = [hourIndex, minuteIndex]
        case .mS: indices = [minuteIndex, secondIndex]
        default: indices = []
        }
        for (i, idx) in indices.prefix(rows.count).enumerated() {
            let r = min(max(idx, 0), max(0, rows[i] - 1))
            if rows[i] > 0 { pickerView.selectRow(r, inComponent: i, animated: animated) }
        }
    }

    @objc private func datePickerValueChanged() {
        mSelectedDate = datePicker.date
        if datePicker.datePickerMode != .countDownTimer {
            let min = minDate ?? .distantPast
            let max = maxDate ?? .distantFuture
            if zhhCompare(mSelectedDate!, target: min, format: dateFormat) == .orderedAscending { mSelectedDate = min }
            if zhhCompare(mSelectedDate!, target: max, format: dateFormat) == .orderedDescending { mSelectedDate = max }
            datePicker.setDate(mSelectedDate!, animated: true)
        }
        mSelectedValue = Date.zhhStringFromDate(mSelectedDate!, format: dateFormat, language: language)
        changeBlock?(mSelectedDate, mSelectedValue)
        if isAutoSelect { resultBlock?(mSelectedDate, mSelectedValue) }
    }

    private func isAnyScrollRolling(in view: UIView?) -> Bool {
        guard let v = view else { return false }
        if let sv = v as? UIScrollView, sv.isDragging || sv.isDecelerating { return true }
        for sub in v.subviews { if isAnyScrollRolling(in: sub) { return true } }
        return false
    }
}

private extension Array {
    subscript(safe i: Int) -> Element? {
        indices.contains(i) ? self[i] : nil
    }
}
