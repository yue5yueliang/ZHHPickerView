//
//  Date+Picker.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import Foundation

private var _sharedCalendar: Calendar?
private var _timeZone: TimeZone?

extension Date {

    // MARK: - 设置日历与时区

    /// 设置日历对象（影响所有使用该工具的日期计算）
    static func zhhSetCalendar(_ calendar: Calendar?) {
        _sharedCalendar = calendar
    }

    /// 获取当前全局日历对象
    static var zhhCalendar: Calendar {
        if _sharedCalendar == nil {
            _sharedCalendar = Calendar(identifier: .gregorian)
        }
        return _sharedCalendar!
    }

    /// 设置当前时区（影响所有日期格式转换）
    static func zhhSetTimeZone(_ tz: TimeZone?) {
        _timeZone = tz
        _sharedCalendar?.timeZone = tz ?? .current
    }

    /// 获取当前使用的时区
    static var zhhTimeZone: TimeZone {
        if _timeZone == nil {
            let offset = TimeZone.current.secondsFromGMT(for: Date())
            _timeZone = TimeZone(secondsFromGMT: offset)
        }
        return _timeZone!
    }

    // MARK: - 日期组成部分

    /// 年份（如 2025）
    var zhhYear: Int { Date.zhhCalendar.component(.year, from: self) }
    /// 月份（1~12）
    var zhhMonth: Int { Date.zhhCalendar.component(.month, from: self) }
    /// 日（1~31）
    var zhhDay: Int { Date.zhhCalendar.component(.day, from: self) }
    /// 小时（0~23）
    var zhhHour: Int { Date.zhhCalendar.component(.hour, from: self) }
    /// 分钟（0~59）
    var zhhMinute: Int { Date.zhhCalendar.component(.minute, from: self) }
    /// 秒（0~59）
    var zhhSecond: Int { Date.zhhCalendar.component(.second, from: self) }
    /// 星期几（1~7，周日为1）
    var zhhWeekday: Int { Date.zhhCalendar.component(.weekday, from: self) }
    /// 当前月的第几周（1~5）
    var zhhMonthWeek: Int { Date.zhhCalendar.component(.weekOfMonth, from: self) }
    /// 当前年中的第几周（1~52）
    var zhhYearWeek: Int { Date.zhhCalendar.component(.weekOfYear, from: self) }
    /// 当前属于第几季度（1~4）
    var zhhQuarter: Int {
        let m = zhhMonth
        if m > 9 { return 4 }
        if m > 6 { return 3 }
        if m > 3 { return 2 }
        return 1
    }

    // MARK: - 日期构造

    /// 创建日期（仅包含年份），格式："yyyy"
    static func zhhSetYear(_ year: Int) -> Date? {
        zhhSetYear(year, month: 0, day: 0, hour: 0, minute: 0, second: 0)
    }

    static func zhhSetYear(_ year: Int, month: Int) -> Date? {
        zhhSetYear(year, month: month, day: 0, hour: 0, minute: 0, second: 0)
    }

    static func zhhSetYear(_ year: Int, month: Int, day: Int) -> Date? {
        zhhSetYear(year, month: month, day: day, hour: 0, minute: 0, second: 0)
    }

    static func zhhSetYear(_ year: Int, month: Int, day: Int, hour: Int) -> Date? {
        zhhSetYear(year, month: month, day: day, hour: hour, minute: 0, second: 0)
    }

    static func zhhSetYear(_ year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date? {
        zhhSetYear(year, month: month, day: day, hour: hour, minute: minute, second: 0)
    }

    static func zhhSetYear(_ year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
        var comp = zhhCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        if year > 0 { comp.year = year }
        if month > 0 { comp.month = month }
        if day > 0 { comp.day = day }
        if hour >= 0 { comp.hour = hour }
        if minute >= 0 { comp.minute = minute }
        if second >= 0 { comp.second = second }
        return zhhCalendar.date(from: comp)
    }

    static func zhhSetMonth(_ month: Int, day: Int) -> Date? {
        zhhSetYear(0, month: month, day: day, hour: 0, minute: 0, second: 0)
    }

    static func zhhSetMonth(_ month: Int, day: Int, hour: Int, minute: Int) -> Date? {
        zhhSetYear(0, month: month, day: day, hour: hour, minute: minute, second: 0)
    }

    static func zhhSetHour(_ hour: Int, minute: Int) -> Date? {
        zhhSetYear(0, month: 0, day: 0, hour: hour, minute: minute, second: 0)
    }

    static func zhhSetHour(_ hour: Int, minute: Int, second: Int) -> Date? {
        zhhSetYear(0, month: 0, day: 0, hour: hour, minute: minute, second: second)
    }

    static func zhhSetMinute(_ minute: Int, second: Int) -> Date? {
        zhhSetYear(0, month: 0, day: 0, hour: 0, minute: minute, second: second)
    }

    static func zhhSetYear(_ year: Int, month: Int, weekOfMonth: Int) -> Date? {
        var comp = zhhCalendar.dateComponents([.year, .month, .weekOfMonth], from: Date())
        if year > 0 { comp.year = year }
        if month > 0 { comp.month = month }
        if weekOfMonth > 0 { comp.weekOfMonth = weekOfMonth }
        return zhhCalendar.date(from: comp)
    }

    static func zhhSetYear(_ year: Int, weekOfYear: Int) -> Date? {
        var comp = zhhCalendar.dateComponents([.year, .weekOfYear], from: Date())
        if year > 0 { comp.year = year }
        if weekOfYear > 0 { comp.weekOfYear = weekOfYear }
        return zhhCalendar.date(from: comp)
    }

    static func zhhSetYear(_ year: Int, quarter: Int) -> Date? {
        var comp = zhhCalendar.dateComponents([.year], from: Date())
        comp.year = year
        comp.month = (quarter - 1) * 3 + 1
        comp.day = 1
        return zhhCalendar.date(from: comp)
    }

    // MARK: - 日期辅助计算

    /// 获取某年某月的天数（自动判断闰年）
    static func zhhGetDaysInYear(_ year: Int, month: Int) -> Int {
        guard month >= 1, month <= 12, year > 0 else { return 0 }
        let leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: return 31
        case 4, 6, 9, 11: return 30
        case 2: return leap ? 29 : 28
        default: return 0
        }
    }

    /// 获取某年某月的周数
    static func zhhGetWeeksOfMonthInYear(_ year: Int, month: Int) -> Int {
        let days = zhhGetDaysInYear(year, month: month)
        guard let d = zhhSetYear(year, month: month, day: days) else { return 0 }
        return zhhCalendar.component(.weekOfMonth, from: d)
    }

    /// 获取某年的总周数（52或53）
    static func zhhGetWeeksOfYearInYear(_ year: Int) -> Int {
        guard let d = zhhSetYear(year, month: 12, day: 31) else { return 52 }
        var w = zhhCalendar.component(.weekOfYear, from: d)
        if w == 1 { w = 52 }
        return w
    }

    /// 获取某年的总季度数（通常为4）
    static func zhhGetQuartersInYear(_ year: Int) -> Int {
        guard let d = zhhSetYear(year, month: 12, day: 31) else { return 4 }
        return zhhCalendar.component(.quarter, from: d)
    }

    /// 获取当前日期加减指定天数后的新日期
    func zhhGetNewDateToDays(_ days: TimeInterval) -> Date {
        addingTimeInterval(86400 * days)
    }

    /// 获取当前日期加减指定月数后的新日期
    func zhhGetNewDateToMonths(_ months: Int) -> Date? {
        Date.zhhCalendar.date(byAdding: .month, value: months, to: self)
    }

    // MARK: - 格式转换

    /// 将 NSDate 转为字符串（可指定语言）
    static func zhhStringFromDate(_ date: Date, format: String, language: String? = nil) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = zhhTimeZone
        f.locale = Locale(identifier: language ?? Locale.preferredLanguages.first ?? "en")
        return f.string(from: date)
    }

    /// 将字符串转为 NSDate（可指定语言）
    static func zhhDateFromString(_ str: String, format: String, language: String? = nil) -> Date? {
        guard !str.isEmpty, !format.isEmpty else { return nil }
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = Locale(identifier: language ?? Locale.preferredLanguages.first ?? "en")
        f.timeZone = zhhTimeZone
        f.isLenient = true
        return f.date(from: str)
    }
}
