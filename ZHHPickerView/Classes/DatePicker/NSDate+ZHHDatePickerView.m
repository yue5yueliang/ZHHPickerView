//
//  NSDate+ZHHDatePickerView.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "NSDate+ZHHDatePickerView.h"

@implementation NSDate (ZHHDatePickerView)

/// 日历对象
static NSCalendar *_sharedCalendar = nil;
/// 时区
static NSTimeZone *_timeZone = nil;

#pragma mark -  设置【日历对象】和【时区】

/// 设置日历对象（影响所有使用该工具的日期计算）
+ (void)zhh_setCalendar:(NSCalendar *)calendar {
    _sharedCalendar = calendar;
}

/// 获取当前全局日历对象
+ (NSCalendar *)zhh_getCalendar {
    if (!_sharedCalendar) {
        // 创建日历对象，指定日历的算法（公历/阳历）
        _sharedCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _sharedCalendar;
}

/// 设置当前时区（影响所有日期格式转换）
+ (void)zhh_setTimeZone:(NSTimeZone *)timeZone {
    _timeZone = timeZone;
    // 同步日历对象时区设置
    [self zhh_getCalendar].timeZone = timeZone;
}

/// 获取当前使用的时区
+ (NSTimeZone *)zhh_getTimeZone {
    if (!_timeZone) {
        // 当前时区
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        // 当前时区相对于GMT(零时区)的偏移秒数
        NSInteger interval = [localTimeZone secondsFromGMTForDate:[NSDate date]];
        // 当前时区(不使用夏时制)：由偏移量获得对应的NSTimeZone对象
        // 注意：一些夏令时时间 NSString 转 NSDate 时，默认会导致 NSDateFormatter 格式化失败，返回 null
        _timeZone = [NSTimeZone timeZoneForSecondsFromGMT:interval];
    }
    return _timeZone;
}

/// NSDate 转 NSDateComponents
+ (NSDateComponents *)zhh_componentsFromDate:(NSDate *)date {
    // 通过日历类 NSCalendar 进行转换
    NSCalendar *calendar = [self zhh_getCalendar];
    // NSDateComponents 可以获得日期的详细信息，即日期的组成
    return [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter) fromDate:date];
}

/// NSDateComponents 转 NSDate
+ (NSDate *)zhh_dateFromComponents:(NSDateComponents *)components {
    // 通过日历类 NSCalendar 进行转换
    NSCalendar *calendar = [self zhh_getCalendar];
    return [calendar dateFromComponents:components];
}

/// 取指定日期的年份（如 2025）
- (NSInteger)zhh_year {
    return [NSDate zhh_componentsFromDate:self].year;
}

/// 取指定日期的月份（如 1~12）
- (NSInteger)zhh_month {
    return [NSDate zhh_componentsFromDate:self].month;
}

/// 获取指定日期的天（如 1~31）
- (NSInteger)zhh_day {
   return [NSDate zhh_componentsFromDate:self].day;
}

/// 获取指定日期的小时（如 0~23）
- (NSInteger)zhh_hour {
    return [NSDate zhh_componentsFromDate:self].hour;
}

/// 获取指定日期的分钟（如 0~59）
- (NSInteger)zhh_minute {
    return [NSDate zhh_componentsFromDate:self].minute;
}

/// 获取指定日期的秒（如 0~59）
- (NSInteger)zhh_second {
    return [NSDate zhh_componentsFromDate:self].second;
}

/// 获取指定日期的星期（如 1~7，周日为1）
- (NSInteger)zhh_weekday {
    return [NSDate zhh_componentsFromDate:self].weekday;
}

/// 获取指定日期的月周（如 1~5）
- (NSInteger)zhh_monthWeek {
    return [NSDate zhh_componentsFromDate:self].weekOfMonth;
}

/// 获取指定日期的年周（如 1~52）
- (NSInteger)zhh_yearWeek {
    return [NSDate zhh_componentsFromDate:self].weekOfYear;
}

/// 获取指定日期的季度（如 1~4）
/// @return 季度值：1-第一季度，2-第二季度，3-第三季度，4-第四季度
/// @note NSDateComponents 的 quarter 属性在某些日历系统中可能返回0，因此手动计算
- (NSInteger)zhh_quarter {
    // 注意：NSDateComponents.quarter 在某些日历系统中可能返回0，因此手动计算
    NSInteger month = self.zhh_month;
    NSInteger quarter = 1;
    
    // 根据月份判断季度
    if (month > 9) {
        quarter = 4; // 10-12月：第四季度
    } else if (month > 6) {
        quarter = 3; // 7-9月：第三季度
    } else if (month > 3) {
        quarter = 2; // 4-6月：第二季度
    } else {
        quarter = 1; // 1-3月：第一季度
    }
    
    return quarter;
}

/// 获取中文星期字符串（如："周一"）
- (NSString *)zhh_weekdayString {
    NSArray<NSString *> *weekdays = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    NSInteger index = self.zhh_weekday - 1;
    if (index >= 0 && index < weekdays.count) {
        return weekdays[index];
    }
    return @"";
}

#pragma mark - 🧱 日期构造（创建指定格式的 NSDate 对象）

/// 创建日期，支持按需设置年/月/日/时/分/秒/周/季度等字段
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second weekOfMonth:(NSInteger)weekOfMonth weekOfYear:(NSInteger)weekOfYear quarter:(NSInteger)quarter {

    // 默认以当前日期为基础
    NSDateComponents *components = [self zhh_componentsFromDate:[NSDate date]];

    if (year > 0)        components.year = year;
    if (month > 0)       components.month = month;
    if (day > 0)         components.day = day;
    if (hour >= 0)       components.hour = hour;
    if (minute >= 0)     components.minute = minute;
    if (second >= 0)     components.second = second;
    if (weekOfMonth > 0) components.weekOfMonth = weekOfMonth;
    if (weekOfYear > 0)  components.weekOfYear = weekOfYear;
    if (quarter > 0)     components.quarter = quarter;
    
    return [self zhh_dateFromComponents:components];
}

/// 创建日期（仅包含年份），格式："yyyy"
+ (NSDate *)zhh_setYear:(NSInteger)year {
    return [self zhh_setYear:year month:0 day:0 hour:0 minute:0 second:0];
}

/// 创建日期（包含年份与月份），格式："yyyy-MM"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month {
    return [self zhh_setYear:year month:month day:0 hour:0 minute:0 second:0];
}

/// 创建日期（包含年月日），格式："yyyy-MM-dd"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    return [self zhh_setYear:year month:month day:day hour:0 minute:0 second:0];
}

/// 创建日期（包含年月日与小时），格式："yyyy-MM-dd HH"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    return [self zhh_setYear:year month:month day:day hour:hour minute:0 second:0];
}

/// 创建日期（包含年月日、小时与分钟），格式："yyyy-MM-dd HH:mm"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    return [self zhh_setYear:year month:month day:day hour:hour minute:minute second:0];
}

/// 创建日期（包含年月日、时分秒），格式："yyyy-MM-dd HH:mm:ss"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    return [self zhh_setYear:year month:month day:day hour:hour minute:minute second:second weekOfMonth:0 weekOfYear:0 quarter:0];
}

/// 创建日期（仅包含月日时分），格式："MM-dd HH:mm"
+ (NSDate *)zhh_setMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    return [self zhh_setYear:0 month:month day:day hour:hour minute:minute second:0];
}

/// 创建日期（仅包含月日），格式："MM-dd"
+ (NSDate *)zhh_setMonth:(NSInteger)month day:(NSInteger)day {
    return [self zhh_setYear:0 month:month day:day hour:0 minute:0 second:0];
}

/// 创建日期（仅包含时分秒），格式："HH:mm:ss"
+ (NSDate *)zhh_setHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    return [self zhh_setYear:0 month:0 day:0 hour:hour minute:minute second:second];
}

/// 创建日期（仅包含时分），格式："HH:mm"
+ (NSDate *)zhh_setHour:(NSInteger)hour minute:(NSInteger)minute {
    return [self zhh_setYear:0 month:0 day:0 hour:hour minute:minute second:0];
}

/// 创建日期（仅包含分秒），格式："mm:ss"
+ (NSDate *)zhh_setMinute:(NSInteger)minute second:(NSInteger)second {
    return [self zhh_setYear:0 month:0 day:0 hour:0 minute:minute second:second];
}

/// 创建日期（指定年月与月内第几周），格式："yyyy-MM-ww"
+ (NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month weekOfMonth:(NSInteger)weekOfMonth {
    return [self zhh_setYear:year month:month day:0 hour:0 minute:0 second:0 weekOfMonth:weekOfMonth weekOfYear:0 quarter:0];
}

/// 创建日期（指定年与年内第几周），格式："yyyy-ww"
+ (NSDate *)zhh_setYear:(NSInteger)year weekOfYear:(NSInteger)weekOfYear {
    return [self zhh_setYear:year month:0 day:0 hour:0 minute:0 second:0 weekOfMonth:0 weekOfYear:weekOfYear quarter:0];
}

/// 创建日期（指定年与季度），格式："yyyy-qq"
+ (NSDate *)zhh_setYear:(NSInteger)year quarter:(NSInteger)quarter {
    return [self zhh_setYear:year month:0 day:0 hour:0 minute:0 second:0 weekOfMonth:0 weekOfYear:0 quarter:quarter];
}

/// 设置12小时制下的 hour 值（如上午/下午 1~12）
- (NSDate *)zhh_setTwelveHour:(NSInteger)hour {
    NSDateComponents *components = [NSDate zhh_componentsFromDate:self];
    if (hour >= 0) {
        components.hour = hour;
    }
    return [NSDate zhh_dateFromComponents:components];
}

#pragma mark - 📊 日期辅助计算

/// 获取指定年月的天数（自动判断是否为闰年）
/// @param year  年份（如：2025）
/// @param month 月份（1~12）
/// @return 天数（28~31，若参数不合法返回 0）
/// @note 使用闰年判断规则：能被4整除但不能被100整除，或能被400整除
+ (NSUInteger)zhh_getDaysInYear:(NSInteger)year month:(NSInteger)month {
    // 参数合法性检查
    if (month < 1 || month > 12 || year <= 0) {
        return 0;
    }
    
    // 判断是否为闰年
    // 规则：能被4整除但不能被100整除，或能被400整除
    BOOL isLeapYear = NO;
    if (year % 4 == 0) {
        if (year % 100 == 0) {
            // 能被100整除的年份，必须能被400整除才是闰年
            isLeapYear = (year % 400 == 0);
        } else {
            // 能被4整除但不能被100整除的年份是闰年
            isLeapYear = YES;
        }
    }

    // 根据月份返回对应天数
    switch (month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31; // 大月：31天
        case 4: case 6: case 9: case 11:
            return 30; // 小月：30天
        case 2:
            return isLeapYear ? 29 : 28; // 2月：闰年29天，平年28天
        default:
            return 0; // 理论上不会执行到这里
    }
}

/// 获取某年某月的周数（通过年月求该月周数）
+ (NSUInteger)zhh_getWeeksOfMonthInYear:(NSInteger)year month:(NSInteger)month {
    NSUInteger lastDayOfMonth = [self zhh_getDaysInYear:year month:month];
    NSDate *endDate = [self zhh_setYear:year month:month day:lastDayOfMonth];
    return endDate.zhh_monthWeek;
}

/// 获取某年的总周数（通过年求该年周数，52或53）
+ (NSUInteger)zhh_getWeeksOfYearInYear:(NSInteger)year {
    NSDate *endDate = [self zhh_setYear:year month:12 day:31];
    NSInteger weeks = endDate.zhh_yearWeek;
    if (weeks == 1) weeks = 52;
    return weeks;
}

/// 获取某年的总季度数（通过年求该年季度数，通常为4）
+ (NSUInteger)zhh_getQuartersInYear:(NSInteger)year {
    NSDate *endDate = [self zhh_setYear:year month:12 day:31];
    return endDate.zhh_quarter;
}

/// 获取当前日期加减指定天数后的新日期
- (NSDate *)zhh_getNewDateToDays:(NSTimeInterval)days {
    // days 为正数时，表示几天之后的日期；负数表示几天之前的日期
    return [self dateByAddingTimeInterval:60 * 60 * 24 * days];
}

/// 获取当前日期加减指定月数后的新日期
/// @param months 月数（正数表示之后，负数表示之前）
/// @return 计算后的新日期对象
/// @note 使用日历对象进行月份计算，能正确处理月份边界情况（如1月31日+1月=2月28/29日）
- (NSDate *)zhh_getNewDateToMonths:(NSTimeInterval)months {
    // 使用日历对象进行月份计算，能正确处理月份边界情况
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    
    // 使用全局日历对象，确保时区和日历算法一致
    NSCalendar *calendar = [NSDate zhh_getCalendar];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

#pragma mark - 🔁 格式转换（NSDate <-> NSString）

/// 将 NSDate 转为字符串（默认使用系统语言和时区）
+ (NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat {
    return [self zhh_stringFromDate:date dateFormat:dateFormat language:nil];
}

/// 将 NSDate 转为字符串（可指定语言）
/// @param date 要转换的日期对象
/// @param dateFormat 日期格式字符串（如：@"yyyy-MM-dd HH:mm:ss"）
/// @param language 语言标识符（如：@"zh-Hans"、@"en"），为 nil 时使用系统首选语言
/// @return 格式化后的日期字符串
/// @note NSDateFormatter 创建成本较高，如需频繁调用建议缓存 formatter 实例
+ (NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat language:(NSString *)language {
    if (!date || !dateFormat) {
        return @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    dateFormatter.dateFormat = dateFormat;
    // 设置时区（不设置默认为系统时区）
    dateFormatter.timeZone = [self zhh_getTimeZone];
    
    // 设置语言环境
    if (!language) {
        language = [NSLocale preferredLanguages].firstObject;
    }
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
    
    // 执行格式化转换
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString ?: @"";
}

/// 将字符串转为 NSDate（默认使用系统语言和时区）
+ (NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat {
    return [self zhh_dateFromString:dateString dateFormat:dateFormat language:nil];
}

/// 将字符串转为 NSDate（可指定语言）
/// @param dateString 日期字符串（如：@"2025-06-12 15:30:00"）
/// @param dateFormat 日期格式字符串（如：@"yyyy-MM-dd HH:mm:ss"）
/// @param language 语言标识符（如：@"zh-Hans"、@"en"），为 nil 时使用系统首选语言
/// @return 解析后的日期对象，解析失败返回 nil
/// @note 设置 lenient=YES 允许宽松解析，如果时间不存在则获取距离最近的整点时间
+ (NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat language:(NSString *)language {
    if (!dateString || dateString.length == 0 || !dateFormat) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    dateFormatter.dateFormat = dateFormat;
    
    // 设置语言环境
    if (!language) {
        language = [NSLocale preferredLanguages].firstObject;
    }
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
    
    // 设置时区
    dateFormatter.timeZone = [self zhh_getTimeZone];
    
    // 启用宽松解析模式：如果时间不存在，就获取距离最近的整点时间
    // 例如：2月30日会被解析为3月2日
    dateFormatter.lenient = YES;
    
    return [dateFormatter dateFromString:dateString];
}

@end
