//
//  ZHHDatePickerView.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHBasePickerView.h"

NS_ASSUME_NONNULL_BEGIN

/// 日期选择器格式类型
typedef NS_ENUM(NSInteger, ZHHDatePickerMode) {
    
#pragma mark - 系统样式（支持国际化格式）

    /// 【yyyy-MM-dd】UIDatePickerModeDate（美式：MM-dd-yyyy，英式：dd-MM-yyyy）
    ZHHDatePickerModeDate,
    
    /// 【yyyy-MM-dd HH:mm】UIDatePickerModeDateAndTime
    ZHHDatePickerModeDateAndTime,
    
    /// 【HH:mm】UIDatePickerModeTime
    ZHHDatePickerModeTime,
    
    /// 【HH:mm】UIDatePickerModeCountDownTimer（倒计时）
    ZHHDatePickerModeCountDownTimer,
    
#pragma mark - 自定义样式（增强扩展支持）

    /// 【yyyy-MM-dd HH:mm:ss】年月日 时分秒
    ZHHDatePickerModeYMDHMS,
    
    /// 【yyyy-MM-dd HH:mm】年月日 时分
    ZHHDatePickerModeYMDHM,
    
    /// 【yyyy-MM-dd HH】年月日 时
    ZHHDatePickerModeYMDH,
    
    /// 【MM-dd HH:mm】月日 时分
    ZHHDatePickerModeMDHM,
    
    /// 【yyyy-MM-dd】年月日（兼容国际化格式）
    ZHHDatePickerModeYMD,
    
    /// 【yyyy-MM】年月（兼容国际化格式）
    ZHHDatePickerModeYM,
    
    /// 【yyyy】年
    ZHHDatePickerModeY,
    
    /// 【MM-dd】月日
    ZHHDatePickerModeMD,
    
    /// 【HH:mm:ss】时分秒
    ZHHDatePickerModeHMS,
    
    /// 【HH:mm】时分
    ZHHDatePickerModeHM,
    
    /// 【mm:ss】分秒
    ZHHDatePickerModeMS,
    
    /// 【yyyy-QQ】年 - 季度（如 Q1 ~ Q4）
    ZHHDatePickerModeYQ,
    
    /// 【yyyy-MM-ww】年月周（第几周）
    ZHHDatePickerModeYMW,
    
    /// 【yyyy-ww】年周（第几周）
    ZHHDatePickerModeYW
};

typedef NS_ENUM(NSInteger, ZHHDateUnitDisplayType) {
    /// 显示在所有行上（默认）
    ZHHDateUnitDisplayTypeAll,
    
    /// 仅显示在中间选中行
    ZHHDateUnitDisplayTypeOnlyCenter,
    
    /// 不显示日期单位（完全隐藏）
    ZHHDateUnitDisplayTypeNone
};

/// 日期选择回调 Block（单个日期）
/// @param selectedDate 选中的日期对象（NSDate）
/// @param selectedValue 选中的日期文本（格式化后的字符串）
typedef void (^ZHHDateResultBlock)(NSDate * _Nullable selectedDate, NSString * _Nullable selectedValue);

/// 日期范围选择回调 Block（起始日期）
/// @param selectedStartDate 选中的开始日期（NSDate）
/// @param selectedEndDate 选中的结束日期（NSDate）
/// @param selectedValue 选中的日期范围文本（格式化后的字符串，如："2025-06-01 ~ 2025-06-10"）
typedef void (^ZHHDateResultRangeBlock)(NSDate * _Nullable selectedStartDate, NSDate * _Nullable selectedEndDate, NSString * _Nullable selectedValue);

@interface ZHHDatePickerView : ZHHBasePickerView

#pragma mark - 基础配置
/// 日期选择器显示类型
@property (nonatomic, assign) ZHHDatePickerMode pickerMode;

/// 当前选中的日期值（建议使用 selectedDate）
@property (nullable, nonatomic, strong) NSDate *selectedDate;

@property (nullable, nonatomic, copy) NSString *selectedValue;

/// 最小日期
@property (nullable, nonatomic, strong) NSDate *minDate;
/// 最大日期
@property (nullable, nonatomic, strong) NSDate *maxDate;

/// 是否自动选择，即滚动选择器后立即执行结果回调，默认 NO
@property (nonatomic, assign) BOOL isAutoSelect;

/// 选择结果回调
@property (nullable, nonatomic, copy) ZHHDateResultBlock resultBlock;

/// 范围选择结果回调：仅对 `ZHHDatePickerModeYQ`、`ZHHDatePickerModeYMW`、`ZHHDatePickerModeYW`生效
@property (nullable, nonatomic, copy) ZHHDateResultRangeBlock resultRangeBlock;

/// 滚动时触发的回调
@property (nullable, nonatomic, copy) ZHHDateResultBlock changeBlock;

/// 滚动范围时触发的回调：仅对 `ZHHDatePickerModeYQ`、`ZHHDatePickerModeYMW`、`ZHHDatePickerModeYW`生效
@property (nullable, nonatomic, copy) ZHHDateResultRangeBlock changeRangeBlock;

/// 当前选择器是否正在滚动（可用于避免滚动未停止时点击“确定”按钮导致数据异常）
@property (nonatomic, readonly, assign, getter=isRolling) BOOL rolling;

#pragma mark - 显示配置

/// 日期单位显示类型
@property (nonatomic, assign) ZHHDateUnitDisplayType unitDisplayType;

/// 是否显示“星期“，默认 NO
@property (nonatomic, assign, getter=isShowWeek) BOOL showWeek;

/// 是否显示“今天”，默认 NO
@property (nonatomic, assign, getter=isShowToday) BOOL showToday;

/// 是否显示“至今”，默认 NO
@property (nonatomic, assign, getter=isShowToNow) BOOL showToNow;

/// 首行自定义内容，配合 selectValue 设置默认选中
@property (nullable, nonatomic, copy) NSString *firstRowContent;

/// 末行自定义内容，配合 selectValue 设置默认选中
@property (nullable, nonatomic, copy) NSString *lastRowContent;

/// 日期数据排序是否降序，默认为 NO（升序）
@property (nonatomic, assign, getter=isDescending) BOOL descending;

/// 是否显示前导零（如：2020-01-01），默认为 NO（如：2020-1-1）
@property (nonatomic, assign, getter=isShowLeadingZero) BOOL showLeadingZero;

/// 是否使用 12 小时制，默认为 NO
@property (nonatomic, assign, getter=isTwelveHourMode) BOOL twelveHourMode;

/// 分钟的间隔，默认1（范围 1 ~ 30）
@property (nonatomic, assign) NSInteger minuteInterval;

/// 秒数的间隔，默认1（范围 1 ~ 30）
@property (nonatomic, assign) NSInteger secondInterval;

/// 倒计时时长，默认0（单位：秒，范围 0 ~ 86399（24*60*60-1））：仅对 `ZHHDatePickerModeCountDownTimer`生效
@property (nonatomic, assign) NSTimeInterval countDownDuration;

#pragma mark - 自定义时间格式

/// 自定义月份数据源
/// 如：@[@"1月", @"2月",..., @"12月"]、 @[@"一月", @"二月",..., @"十二月"]、 @[@"Jan", @"Feb",..., @"Dec"] 等
@property (nonatomic, copy) NSArray <NSString *> *monthNames;

/// 是否使用国际化环境下的月份简称（如 "Jan" 而非 "January"），默认为 NO
/// 仅适用于 `ZHHDatePickerModeYMD` 与 `ZHHDatePickerModeYM` 模式
@property (nonatomic, assign, getter=isUseShortMonthNames) BOOL useShortMonthNames;

/// 自定义日期单位显示
/// 格式：@{@"year": @"年", @"month": @"月", @"day": @"日", @"hour": @"时", @"minute": @"分", @"second": @"秒"}
@property (nonatomic, copy) NSDictionary *customUnit;

/// 是否显示上午/下午，默认 NO：仅对 `ZHHDatePickerModeYMDH`生效
@property (nonatomic, assign, getter=isShowAMAndPM) BOOL showAMAndPM;

#pragma mark - 时区和日历

/// 自定义时区，默认为当前时区
/// 如：timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"]; // 如：设置时区为 美国纽约
/// 特别提示：如果有设置自定义时区，需要把有使用 NSDate+BRPickerView 分类中方法的代码（如：设置minDate、maxDate等） 放在设置时区代码的后面，目的是同步时区设置到 NSDate+BRPickerView 分类中
@property (nullable, nonatomic, copy) NSTimeZone *timeZone;

/// 设置日历对象，可以指定日历的算法。default is [NSCalendar currentCalendar]. setting nil returns to default. for `UIDatePicker`, ignored otherwise.
/// 如：calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese]; // 设置中国农历（阴历）日期
@property (nullable, nonatomic, copy) NSCalendar *calendar;

#pragma mark - 无效日期

/// 指定不允许选择的日期列表
@property (nullable, nonatomic, copy) NSArray <NSDate *> *nonSelectableDates;

/// 当选择到不允许的日期时触发的回调
@property (nullable, nonatomic, copy) ZHHDateResultBlock didSelectNonSelectableDateBlock;

#pragma mark - 样式配置

/// 设置 picker 的行高，默认为 40
@property (nonatomic, assign) CGFloat pickerRowHeight;

/// 设置 picker 的列宽
@property (nonatomic, assign) CGFloat columnWidth;

/// 设置 picker 文本的颜色，默认为 [UIColor labelColor]
@property (nullable, nonatomic, strong) UIColor *pickerTextColor;

/// 设置 picker 文本的字体，默认为 [UIFont systemFontOfSize:22.0f]
@property (nullable, nonatomic, strong) UIFont *pickerTextFont;

/// 设置 picker 选中行文本的颜色，默认为 [UIColor labelColor]
@property (nullable, nonatomic, strong) UIColor *pickerSelectedTextColor;

/// 设置 picker 选中行文本的字体，默认为 [UIFont systemFontOfSize:18.0f]
@property (nullable, nonatomic, strong) UIFont *pickerSelectedTextFont;

/// 设置 picker 文本支持的最大行数，默认为 2
@property (nonatomic, assign) NSUInteger maxTextLines;

#pragma mark - 日期单位样式配置（仅在 unitDisplayType == ZHHDateUnitDisplayTypeOnlyCenter 时生效，暂不支持前 4 种日期选择器类型）

/// 日期单位文本颜色（仅居中单位样式生效）
@property (nullable, nonatomic, strong) UIColor *dateUnitTextColor;

/// 日期单位文本字体（仅居中单位样式生效）
@property (nullable, nonatomic, strong) UIFont *dateUnitTextFont;

/// 日期单位 Label 的水平偏移量（仅居中单位样式生效）
@property (nonatomic, assign) CGFloat dateUnitOffsetX;

/// 日期单位 Label 的垂直偏移量（仅居中单位样式生效）
@property (nonatomic, assign) CGFloat dateUnitOffsetY;

/// 设置语言（如：@"zh-Hans" 简体，@"zh-Hant" 繁体，@"en" 英文；不设置或为nil时 表示跟随系统）
@property(nullable, nonatomic, copy) NSString *language;

#pragma mark - 初始化

/// 初始化日期选择器
/// @param pickerMode  日期选择器显示类型
- (instancetype)initWithPickerMode:(ZHHDatePickerMode)pickerMode;

// 获取列宽(组件内部方法)
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
@end

NS_ASSUME_NONNULL_END
