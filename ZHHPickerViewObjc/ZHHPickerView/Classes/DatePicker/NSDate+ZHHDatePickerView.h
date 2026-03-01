//
//  NSDate+ZHHDatePickerView.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (ZHHDatePickerView)

#pragma mark - 设置日历与时区（全局配置）

/// 设置日历对象（影响所有使用该工具的日期计算）
+ (void)zhh_setCalendar:(NSCalendar *)calendar;

/// 获取当前全局日历对象
+ (NSCalendar *)zhh_getCalendar;

/// 设置当前时区（影响所有日期格式转换）
+ (void)zhh_setTimeZone:(NSTimeZone *)timeZone;

/// 获取当前使用的时区
+ (NSTimeZone *)zhh_getTimeZone;

/// 获取日期的各组成部分信息
@property (nonatomic, readonly) NSInteger zhh_year;         ///< 年份（如 2025）
@property (nonatomic, readonly) NSInteger zhh_month;        ///< 月份（1~12）
@property (nonatomic, readonly) NSInteger zhh_day;          ///< 日（1~31）
@property (nonatomic, readonly) NSInteger zhh_hour;         ///< 小时（0~23）
@property (nonatomic, readonly) NSInteger zhh_minute;       ///< 分钟（0~59）
@property (nonatomic, readonly) NSInteger zhh_second;       ///< 秒（0~59）
@property (nonatomic, readonly) NSInteger zhh_weekday;      ///< 星期几（1~7，周日为1）
@property (nonatomic, readonly) NSInteger zhh_monthWeek;    ///< 当前月的第几周（1~5）
@property (nonatomic, readonly) NSInteger zhh_yearWeek;     ///< 当前年中的第几周（1~52）
@property (nonatomic, readonly) NSInteger zhh_quarter;      ///< 当前属于第几季度（1~4）

/// 获取中文星期字符串（如："星期一"）
@property (nullable, nonatomic, readonly, copy) NSString *zhh_weekdayString;

#pragma mark - 🧱 日期构造（创建指定格式的 NSDate 对象）

/// 创建日期（仅包含年份），格式："yyyy"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year;

/// 创建日期（包含年份与月份），格式："yyyy-MM"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month;

/// 创建日期（包含年月日），格式："yyyy-MM-dd"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/// 创建日期（包含年月日与小时），格式："yyyy-MM-dd HH"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour;

/// 创建日期（包含年月日、小时与分钟），格式："yyyy-MM-dd HH:mm"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

/// 创建日期（包含年月日、时分秒），格式："yyyy-MM-dd HH:mm:ss"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/// 创建日期（仅包含月日时分），格式："MM-dd HH:mm"
+ (nullable NSDate *)zhh_setMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

/// 创建日期（仅包含月日），格式："MM-dd"
+ (nullable NSDate *)zhh_setMonth:(NSInteger)month day:(NSInteger)day;

/// 创建日期（仅包含时分秒），格式："HH:mm:ss"
+ (nullable NSDate *)zhh_setHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/// 创建日期（仅包含时分），格式："HH:mm"
+ (nullable NSDate *)zhh_setHour:(NSInteger)hour minute:(NSInteger)minute;

/// 创建日期（仅包含分秒），格式："mm:ss"
+ (nullable NSDate *)zhh_setMinute:(NSInteger)minute second:(NSInteger)second;

/// 创建日期（指定年月与月内第几周），格式："yyyy-MM-ww"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year month:(NSInteger)month weekOfMonth:(NSInteger)weekOfMont;

/// 创建日期（指定年与年内第几周），格式："yyyy-ww"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year weekOfYear:(NSInteger)weekOfYear;

/// 创建日期（指定年与季度），格式："yyyy-qq"
+ (nullable NSDate *)zhh_setYear:(NSInteger)year quarter:(NSInteger)quarter;

/// 设置12小时制下的 hour 值（如上午/下午 1~12）
- (NSDate *)zhh_setTwelveHour:(NSInteger)hour;

#pragma mark - 📊 日期辅助计算

/// 获取某年某月的天数（例如：2月为28或29）
+ (NSUInteger)zhh_getDaysInYear:(NSInteger)year month:(NSInteger)month;

/// 获取某年某月的周数（通过年月求该月周数）
+ (NSUInteger)zhh_getWeeksOfMonthInYear:(NSInteger)year month:(NSInteger)month;

/// 获取某年的总周数（通过年求该年周数，52或53）
+ (NSUInteger)zhh_getWeeksOfYearInYear:(NSInteger)year;

/// 获取某年的总季度数（通过年求该年季度数，通常为4）
+ (NSUInteger)zhh_getQuartersInYear:(NSInteger)year;

/// 获取当前日期加减指定天数后的新日期
- (nullable NSDate *)zhh_getNewDateToDays:(NSTimeInterval)days;

/// 获取当前日期加减指定月数后的新日期
- (nullable NSDate *)zhh_getNewDateToMonths:(NSTimeInterval)months;

#pragma mark - 🔁 格式转换（NSDate <-> NSString）

/// 将 NSDate 转为字符串（默认使用系统语言和时区）
+ (nullable NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

/// 将 NSDate 转为字符串（可指定语言）
+ (nullable NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat language:(nullable NSString *)language;

/// 将字符串转为 NSDate（默认使用系统语言和时区）
+ (nullable NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat;

/// 将字符串转为 NSDate（可指定语言）
+ (nullable NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat language:(nullable NSString *)language;

@end

NS_ASSUME_NONNULL_END
