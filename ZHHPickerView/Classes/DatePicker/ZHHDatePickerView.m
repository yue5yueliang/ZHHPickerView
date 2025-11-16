//
//  ZHHDatePickerView.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDatePickerView.h"
#import "NSDate+ZHHDatePickerView.h"
#import "ZHHDatePickerView+Utilities.h"
#import "NSBundle+ZHHDatePickerView.h"

/// 日期选择器的样式类型
typedef NS_ENUM(NSInteger, ZHHDatePickerStyle) {
    /// 系统样式（使用系统原生的 UIDatePicker，支持国际化格式）
    ZHHDatePickerStyleSystem,
    
    /// 自定义样式（基于 UIPickerView 构建，支持更灵活的格式配置）
    ZHHDatePickerStyleCustom
};

@interface ZHHDatePickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

#pragma mark - 私有属性

/// 日期选择器模式（UIDatePickerMode）
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

/// 容器视图
@property (nonatomic, strong) UIView *containerView;

/// 设置minDate时，是否调整日期联动选择（解决联动异常问题）
@property (nonatomic, assign) BOOL isAdjustSelectRow;

#pragma mark - 视图控件
/// 系统样式的日期选择器（UIDatePicker，适用于 ZHHDatePickerStyleSystem）
@property (nonatomic, strong) UIDatePicker *datePicker;

/// 自定义样式的日期选择器（UIPickerView，适用于 ZHHDatePickerStyleCustom）
@property (nonatomic, strong) UIPickerView *pickerView;

#pragma mark - 日期数据源数组

/// 年份数据数组（如：@"2020", @"2021", @"2022"...）
@property (nonatomic, copy) NSArray *yearArr;

/// 月份数据数组（如：@"01", @"02", ..., @"12"）
@property (nonatomic, copy) NSArray *monthArr;

/// 日期数据数组（如：@"01", @"02", ..., @"31"）
@property (nonatomic, copy) NSArray *dayArr;

/// 小时数据数组（如：@"00", @"01", ..., @"23"）
@property (nonatomic, copy) NSArray *hourArr;

/// 分钟数据数组（如：@"00", @"01", ..., @"59"）
@property (nonatomic, copy) NSArray *minuteArr;

/// 秒钟数据数组（如：@"00", @"01", ..., @"59"）
@property (nonatomic, copy) NSArray *secondArr;

/// 月周数组（如：@"第1周", @"第2周", ..., @"第5周"）
/// 用于 ZHHDatePickerModeYMW（年月周）模式
@property (nonatomic, copy) NSArray *monthWeekArr;

/// 年周数组（如：@"第1周", @"第2周", ..., @"第52周"）
/// 用于 ZHHDatePickerModeYW（年周）模式
@property (nonatomic, copy) NSArray *yearWeekArr;

/// 季度数组（如：@"第一季度", @"第二季度", @"第三季度", @"第四季度"）
/// 用于 ZHHDatePickerModeYQ（年季度）模式
@property (nonatomic, copy) NSArray *quarterArr;

#pragma mark - 当前选中索引

/// 当前选中的年份索引（用于滚轮选中项的定位）
@property (nonatomic, assign) NSInteger yearIndex;

/// 当前选中的月份索引
@property (nonatomic, assign) NSInteger monthIndex;

/// 当前选中的日期索引
@property (nonatomic, assign) NSInteger dayIndex;

/// 当前选中的小时索引
@property (nonatomic, assign) NSInteger hourIndex;

/// 当前选中的分钟索引
@property (nonatomic, assign) NSInteger minuteIndex;

/// 当前选中的秒钟索引
@property (nonatomic, assign) NSInteger secondIndex;

/// 当前选中的月周索引（用于滚轮选中项的定位）
@property (nonatomic, assign) NSInteger monthWeekIndex;

/// 当前选中的年周索引
@property (nonatomic, assign) NSInteger yearWeekIndex;

/// 当前选中的季度索引
@property (nonatomic, assign) NSInteger quarterIndex;

#pragma mark - 滚动中记录

/// 当前正在滚动的组件索引（component）
@property (nonatomic, assign) NSInteger rollingComponent;

/// 当前正在滚动的行索引（row）
@property (nonatomic, assign) NSInteger rollingRow;

#pragma mark - 选择结果

/// 当前选择的日期值
@property (nonatomic, strong) NSDate *mSelectedDate;

/// 当前选择的日期字符串（格式化后的值）
@property (nonatomic, copy) NSString *mSelectedValue;

#pragma mark - 样式与格式

/// 日期选择器的样式类型（系统或自定义）
@property (nonatomic, assign) ZHHDatePickerStyle pickerStyle;

/// 日期格式字符串，用于格式化显示
@property (nonatomic, copy) NSString *dateFormat;

/// 日期单位数组，如 @[@"年", @"月", @"日"]
@property (nonatomic, copy) NSArray<NSString *> *unitArr;

/// 显示单位的 UILabel 数组
@property (nonatomic, copy) NSArray<UILabel *> *unitLabelArr;

@end

@implementation ZHHDatePickerView

#pragma mark - 初始化与数据配置

/// 初始化自定义选择器
- (instancetype)initWithPickerMode:(ZHHDatePickerMode)pickerMode {
    if (self = [super init]) {
        self.pickerMode = pickerMode;
        self.pickerTextFont = [UIFont systemFontOfSize:22.0f];
        self.pickerTextColor = [UIColor labelColor];
        self.maxTextLines = 2;
        self.pickerRowHeight = 40;
        self.language = @"zh-Hans";
    }
    return self;
}

/// 配置选择器数据和默认选中状态
/// @note 确保 dateFormat 已设置，如果未设置则先设置日期格式
- (void)configurePickerData {
    // 0.确保日期格式已设置（如果还未设置，先设置）
    if (!self.dateFormat || self.dateFormat.length == 0) {
        [self setupDateFormatter:self.pickerMode];
    }
    
    // 1.最小日期限制
    self.minDate = [self zhh_handlerMinDate:self.minDate];
    // 2.最大日期限制
    self.maxDate = [self zhh_handlerMaxDate:self.maxDate];
    
    // 确保 dateFormat 不为空后再比较日期
    NSString *format = self.dateFormat ?: @"yyyy-MM-dd HH:mm:ss";
    BOOL minMoreThanMax = [self zhh_compareDate:self.minDate targetDate:self.maxDate dateFormat:format] == NSOrderedDescending;
    if (minMoreThanMax) {
        NSLog(@"最小日期不能大于最大日期！");
        // 如果最小日期大于了最大日期，就忽略两个值
        self.minDate = [NSDate distantPast]; // 0000-12-30 00:00:00 +0000
        self.maxDate = [NSDate distantFuture]; // 4001-01-01 00:00:00 +0000
    }

    // 3.默认选中的日期
    self.mSelectedDate = [self zhh_handlerSelectedDate:self.selectedDate dateFormat:format];

    // 4.设置选择器日期数据
    if (self.pickerStyle == ZHHDatePickerStyleCustom) {
        [self setupDateArray];
    }
    
    if (self.selectedValue && ([self.selectedValue isEqualToString:self.lastRowContent] || [self.selectedValue isEqualToString:self.firstRowContent])) {
        self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
    } else {
        if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
            self.hourIndex = (self.mSelectedDate.zhh_hour < 12 ? 0 : 1);
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d %@", (int)self.mSelectedDate.zhh_year, (int)self.mSelectedDate.zhh_month, (int)self.mSelectedDate.zhh_day, [self getHourString]];
        } else {
            self.mSelectedValue = [self zhh_stringFromDate:self.mSelectedDate dateFormat:self.dateFormat];
        }
    }
}

#pragma mark - 设置默认日期数据源
- (void)setupDateArray {
    if (self.selectedValue && ([self.selectedValue isEqualToString:self.lastRowContent] || [self.selectedValue isEqualToString:self.firstRowContent])) {
        switch (self.pickerMode) {
            case ZHHDatePickerModeYMDHMS:
            case ZHHDatePickerModeYMDHM:
            case ZHHDatePickerModeYMDH:
            case ZHHDatePickerModeYMD:
            case ZHHDatePickerModeYM:
            case ZHHDatePickerModeY:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = nil;
                self.dayArr = nil;
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
                self.monthWeekArr = nil;
                self.yearWeekArr = nil;
                self.quarterArr = nil;
            }
                break;
            case ZHHDatePickerModeMDHM:
            case ZHHDatePickerModeMD:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = [self zhh_monthArrayWithYear:self.mSelectedDate.zhh_year];
                self.dayArr = nil;
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
                self.monthWeekArr = nil;
                self.yearWeekArr = nil;
                self.quarterArr = nil;
            }
                break;
            case ZHHDatePickerModeHMS:
            case ZHHDatePickerModeHM:
            {
                // 时分秒/时分模式：只需要时间相关的数组，不需要年月日
                // 注意：对于时分秒模式，hourArr 应该不依赖年月日，但为了兼容现有逻辑，仍使用当前日期
                // 如果 mSelectedDate 为 nil，使用当前日期
                NSDate *baseDate = self.mSelectedDate ?: [NSDate date];
                self.yearArr = nil;
                self.monthArr = nil;
                self.dayArr = nil;
                self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
                // 对于 HMS 模式，需要初始化 minuteArr 和 secondArr
                if (self.pickerMode == ZHHDatePickerModeHMS) {
                    self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
                    self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour minute:baseDate.zhh_minute];
                } else {
                    // HM 模式只需要 minuteArr
                    self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
                    self.secondArr = nil;
                }
                self.monthWeekArr = nil;
                self.yearWeekArr = nil;
                self.quarterArr = nil;
            }
                break;
            case ZHHDatePickerModeMS:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = [self zhh_monthArrayWithYear:self.mSelectedDate.zhh_year];
                self.dayArr = [self zhh_dayArrayWithYear:self.mSelectedDate.zhh_year month:self.mSelectedDate.zhh_month];
                self.hourArr = [self zhh_hourArrayWithYear:self.mSelectedDate.zhh_year month:self.mSelectedDate.zhh_month day:self.mSelectedDate.zhh_day];
                self.minuteArr = [self zhh_minuteArrayWithYear:self.mSelectedDate.zhh_year month:self.mSelectedDate.zhh_month day:self.mSelectedDate.zhh_day hour:self.mSelectedDate.zhh_hour];
                self.secondArr = nil;
                self.monthWeekArr = nil;
                self.yearWeekArr = nil;
                self.quarterArr = nil;
            }
                break;
            case ZHHDatePickerModeYMW:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = [self zhh_monthArrayWithYear:self.mSelectedDate.zhh_year];
                self.monthWeekArr = [self zhh_monthWeekArrayWithYear:self.mSelectedDate.zhh_year month:self.mSelectedDate.zhh_month];
                self.yearWeekArr = nil;
                self.quarterArr = nil;
                self.dayArr = nil;
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
            }
                break;
            case ZHHDatePickerModeYW:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = nil;
                self.monthWeekArr = nil;
                self.yearWeekArr = [self zhh_yearWeekArrayWithYear:self.mSelectedDate.zhh_year];
                self.quarterArr = nil;
                self.dayArr = nil;
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
            }
                break;
            case ZHHDatePickerModeYQ:
            {
                self.yearArr = [self zhh_yearArray];
                self.monthArr = nil;
                self.monthWeekArr = nil;
                self.yearWeekArr = nil;
                self.quarterArr = [self zhh_quarterArrayWithYear:self.mSelectedDate.zhh_year];;
                self.dayArr = nil;
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
            }
                break;
                
            default:
                break;
        }
    } else {
        // 根据不同的选择器模式，初始化相应的数组
        NSDate *baseDate = self.mSelectedDate ?: [NSDate date];
        
        // 对于时分秒/时分模式，只初始化时间相关数组
        if (self.pickerMode == ZHHDatePickerModeHMS || self.pickerMode == ZHHDatePickerModeHM) {
            self.yearArr = nil;
            self.monthArr = nil;
            self.dayArr = nil;
            self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
            self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
            if (self.pickerMode == ZHHDatePickerModeHMS) {
                self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour minute:baseDate.zhh_minute];
            } else {
                self.secondArr = nil;
            }
            self.monthWeekArr = nil;
            self.yearWeekArr = nil;
            self.quarterArr = nil;
        } else if (self.pickerMode == ZHHDatePickerModeMS) {
            // 分秒模式：只初始化分钟和秒钟数组
            self.yearArr = nil;
            self.monthArr = nil;
            self.dayArr = nil;
            self.hourArr = nil;
            self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
            self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour minute:baseDate.zhh_minute];
            self.monthWeekArr = nil;
            self.yearWeekArr = nil;
            self.quarterArr = nil;
        } else if (self.pickerMode == ZHHDatePickerModeMDHM || self.pickerMode == ZHHDatePickerModeMD) {
            // 月日模式：只初始化月份和日期相关数组
            self.yearArr = nil;
            self.monthArr = [self zhh_monthArrayWithYear:baseDate.zhh_year];
            self.dayArr = [self zhh_dayArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month];
            if (self.pickerMode == ZHHDatePickerModeMDHM) {
                self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
                self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
                self.secondArr = nil;
            } else {
                self.hourArr = nil;
                self.minuteArr = nil;
                self.secondArr = nil;
            }
            self.monthWeekArr = nil;
            self.yearWeekArr = nil;
            self.quarterArr = nil;
        } else {
            // 其他模式：初始化所有相关数组
            self.yearArr = [self zhh_yearArray];
            self.monthArr = [self zhh_monthArrayWithYear:baseDate.zhh_year];
            self.dayArr = [self zhh_dayArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month];
            self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
            self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
            self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour minute:baseDate.zhh_minute];
            
            self.monthWeekArr = [self zhh_monthWeekArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month];
            self.yearWeekArr = [self zhh_yearWeekArrayWithYear:baseDate.zhh_year];
            self.quarterArr = [self zhh_quarterArrayWithYear:baseDate.zhh_year];
        }
    }
}

- (void)setupDateFormatter:(ZHHDatePickerMode)mode {
    switch (mode) {
        case ZHHDatePickerModeDate:
        {
            self.dateFormat = @"yyyy-MM-dd";
            self.pickerStyle = ZHHDatePickerStyleSystem;
            _datePickerMode = UIDatePickerModeDate;
        }
            break;
        case ZHHDatePickerModeDateAndTime:
        {
            self.dateFormat = @"yyyy-MM-dd HH:mm";
            self.pickerStyle = ZHHDatePickerStyleSystem;
            _datePickerMode = UIDatePickerModeDateAndTime;
        }
            break;
        case ZHHDatePickerModeTime:
        {
            self.dateFormat = @"HH:mm";
            self.pickerStyle = ZHHDatePickerStyleSystem;
            _datePickerMode = UIDatePickerModeTime;
        }
            break;
        case ZHHDatePickerModeCountDownTimer:
        {
            self.dateFormat = @"HH:mm";
            self.pickerStyle = ZHHDatePickerStyleSystem;
            _datePickerMode = UIDatePickerModeCountDownTimer;
        }
            break;
            
        case ZHHDatePickerModeYMDHMS:
        {
            self.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_monthUnit], [self zhh_dayUnit], [self zhh_hourUnit], [self zhh_minuteUnit], [self zhh_secondUnit]];
        }
            break;
        case ZHHDatePickerModeYMDHM:
        {
            self.dateFormat = @"yyyy-MM-dd HH:mm";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_monthUnit], [self zhh_dayUnit], [self zhh_hourUnit], [self zhh_minuteUnit]];
        }
            break;
        case ZHHDatePickerModeYMDH:
        {
            self.dateFormat = @"yyyy-MM-dd HH";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_monthUnit], [self zhh_dayUnit], self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM ? @"" : [self zhh_hourUnit]];
        }
            break;
        case ZHHDatePickerModeMDHM:
        {
            self.dateFormat = @"MM-dd HH:mm";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_hourUnit], [self zhh_dayUnit], [self zhh_hourUnit], [self zhh_minuteUnit]];
        }
            break;
        case ZHHDatePickerModeYMD:
        {
            self.dateFormat = @"yyyy-MM-dd";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_monthUnit], [self zhh_dayUnit]];
        }
            break;
        case ZHHDatePickerModeYM:
        {
            self.dateFormat = @"yyyy-MM";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_monthUnit]];
        }
            break;
        case ZHHDatePickerModeY:
        {
            self.dateFormat = @"yyyy";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit]];
        }
            break;
        case ZHHDatePickerModeMD:
        {
            self.dateFormat = @"MM-dd";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_monthUnit], [self zhh_dayUnit]];
        }
            break;
        case ZHHDatePickerModeHMS:
        {
            self.dateFormat = @"HH:mm:ss";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_hourUnit], [self zhh_minuteUnit], [self zhh_secondUnit]];
        }
            break;
        case ZHHDatePickerModeHM:
        {
            self.dateFormat = @"HH:mm";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_hourUnit], [self zhh_minuteUnit]];
        }
            break;
        case ZHHDatePickerModeMS:
        {
            self.dateFormat = @"mm:ss";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_minuteUnit], [self zhh_secondUnit]];
        }
            break;
        case ZHHDatePickerModeYMW:
        {
            self.dateFormat = @"yyyy-MM-WW";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_minuteUnit], [self zhh_weekUnit]];
        }
            break;
        case ZHHDatePickerModeYW:
        {
            self.dateFormat = @"yyyy-ww";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_weekUnit]];
        }
            break;
        case ZHHDatePickerModeYQ:
        {
            self.dateFormat = @"yyyy-qq";
            self.pickerStyle = ZHHDatePickerStyleCustom;
            self.unitArr = @[[self zhh_yearUnit], [self zhh_quarterUnit]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 更新日期数据源数组
- (void)reloadDateArrayWithUpdateMonth:(BOOL)updateMonth updateDay:(BOOL)updateDay updateHour:(BOOL)updateHour updateMinute:(BOOL)updateMinute updateSecond:(BOOL)updateSecond {
    [self reloadDateArrayWithUpdateMonth:updateMonth updateDay:updateDay updateHour:updateHour updateMinute:updateMinute updateSecond:updateSecond updateWeekOfMonth:NO updateWeekOfYear:NO updateQuarter:NO];
}

- (void)reloadDateArrayWithUpdateMonth:(BOOL)updateMonth updateDay:(BOOL)updateDay updateHour:(BOOL)updateHour updateMinute:(BOOL)updateMinute updateSecond:(BOOL)updateSecond updateWeekOfMonth:(BOOL)updateWeekOfMonth updateWeekOfYear:(BOOL)updateWeekOfYear updateQuarter:(BOOL)updateQuarter {
    _isAdjustSelectRow = NO;
    
    // 对于时分秒/时分模式，不依赖年月日，直接处理时间数组
    if (self.pickerMode == ZHHDatePickerModeHMS || self.pickerMode == ZHHDatePickerModeHM) {
        NSDate *baseDate = self.mSelectedDate ?: [NSDate date];
        
        // 更新 hourArr（如果需要）
        if (updateHour) {
            NSString *lastSelectedHour = [self zhh_stringWithNumber:baseDate.zhh_hour];
            self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
            if (self.mSelectedDate && self.hourArr.count > 0) {
                if ([self.hourArr containsObject:lastSelectedHour]) {
                    NSInteger hourIndex = [self.hourArr indexOfObject:lastSelectedHour];
                    if (hourIndex != self.hourIndex) {
                        _isAdjustSelectRow = YES;
                        self.hourIndex = hourIndex;
                    }
                } else {
                    _isAdjustSelectRow = YES;
                    self.hourIndex = ([lastSelectedHour intValue] < [self.hourArr.firstObject intValue]) ? 0 : (self.hourArr.count - 1);
                }
            }
        }
        
        // 更新 minuteArr（如果需要）
        if (updateMinute && self.hourArr.count > 0) {
            NSString *hourString = [self getHourString];
            if (![hourString isEqualToString:self.lastRowContent] && ![hourString isEqualToString:self.firstRowContent]) {
                NSString *lastSelectedMinute = [self zhh_stringWithNumber:baseDate.zhh_minute];
                self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:[hourString integerValue]];
                if (self.mSelectedDate && self.minuteArr.count > 0) {
                    if ([self.minuteArr containsObject:lastSelectedMinute]) {
                        NSInteger minuteIndex = [self.minuteArr indexOfObject:lastSelectedMinute];
                        if (minuteIndex != self.minuteIndex) {
                            _isAdjustSelectRow = YES;
                            self.minuteIndex = minuteIndex;
                        }
                    } else {
                        _isAdjustSelectRow = YES;
                        self.minuteIndex = ([lastSelectedMinute intValue] < [self.minuteArr.firstObject intValue]) ? 0 : (self.minuteArr.count - 1);
                    }
                }
            }
        }
        
        // 更新 secondArr（仅 HMS 模式需要）
        if (updateSecond && self.pickerMode == ZHHDatePickerModeHMS && self.minuteArr.count > 0) {
            NSString *minuteString = [self getMinuteString];
            if (![minuteString isEqualToString:self.lastRowContent] && ![minuteString isEqualToString:self.firstRowContent]) {
                NSString *lastSelectedSecond = [self zhh_stringWithNumber:baseDate.zhh_second];
                NSString *hourString = [self getHourString];
                self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:[hourString integerValue] minute:[minuteString integerValue]];
                if (self.mSelectedDate && self.secondArr.count > 0) {
                    if ([self.secondArr containsObject:lastSelectedSecond]) {
                        NSInteger secondIndex = [self.secondArr indexOfObject:lastSelectedSecond];
                        if (secondIndex != self.secondIndex) {
                            _isAdjustSelectRow = YES;
                            self.secondIndex = secondIndex;
                        }
                    } else {
                        _isAdjustSelectRow = YES;
                        self.secondIndex = ([lastSelectedSecond intValue] < [self.secondArr.firstObject intValue]) ? 0 : (self.secondArr.count - 1);
                    }
                }
            }
        }
        
        return;
    }
    
    // 1.更新 monthArr（需要年月日的模式）
    if (self.yearArr.count == 0) {
        return;
    }
    NSString *yearString = [self getYearString];
    if ((self.lastRowContent && [yearString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [yearString isEqualToString:self.firstRowContent])) {
        self.monthArr = nil;
        self.dayArr = nil;
        self.hourArr = nil;
        self.minuteArr = nil;
        self.secondArr = nil;
        self.monthWeekArr = nil;
        self.yearWeekArr = nil;
        self.quarterArr = nil;
        
        return;
    }
    if (updateMonth) {
        NSString *lastSelectedMonth = [self zhh_stringWithNumber:self.mSelectedDate.zhh_month];
        self.monthArr = [self zhh_monthArrayWithYear:[yearString integerValue]];
        if (self.mSelectedDate) {
            if ([self.monthArr containsObject:lastSelectedMonth]) {
                NSInteger monthIndex = [self.monthArr indexOfObject:lastSelectedMonth];
                if (monthIndex != self.monthIndex) {
                    _isAdjustSelectRow = YES;
                    self.monthIndex = monthIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.monthIndex = ([lastSelectedMonth intValue] < [self.monthArr.firstObject intValue]) ? 0 : (self.monthArr.count - 1);
            }
        }
    }
    
    // 1/1.更新 yearWeekArr
    if (updateWeekOfYear) {
        NSString *lastSelectedWeekOfYear = [self zhh_stringWithNumber:self.mSelectedDate.zhh_yearWeek];
        self.yearWeekArr = [self zhh_yearWeekArrayWithYear:[yearString integerValue]];
        if (self.mSelectedDate) {
            if ([self.yearWeekArr containsObject:lastSelectedWeekOfYear]) {
                NSInteger yearWeekIndex = [self.yearWeekArr indexOfObject:lastSelectedWeekOfYear];
                if (yearWeekIndex != self.yearWeekIndex) {
                    _isAdjustSelectRow = YES;
                    self.monthIndex = yearWeekIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.yearWeekIndex = ([lastSelectedWeekOfYear intValue] < [self.yearWeekArr.firstObject intValue]) ? 0 : (self.yearWeekArr.count - 1);
            }
        }
    }
    
    // 1/1.更新 quarterArr
    if (updateQuarter) {
        NSString *lastSelectedQuarter = [self zhh_stringWithNumber:self.mSelectedDate.zhh_quarter];
        self.quarterArr = [self zhh_quarterArrayWithYear:[yearString integerValue]];
        if (self.mSelectedDate) {
            if ([self.quarterArr containsObject:lastSelectedQuarter]) {
                NSInteger quarterIndex = [self.quarterArr indexOfObject:lastSelectedQuarter];
                if (quarterIndex != self.quarterIndex) {
                    _isAdjustSelectRow = YES;
                    self.quarterIndex = quarterIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.quarterIndex = ([lastSelectedQuarter intValue] < [self.quarterArr.firstObject intValue]) ? 0 : (self.quarterArr.count - 1);
            }
        }
    }
    
    // 2.更新 dayArr
    if (self.monthArr.count == 0) {
        return;
    }
    NSString *monthString = [self getMonthString];
    if ((self.lastRowContent && [monthString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [monthString isEqualToString:self.firstRowContent])) {
        self.dayArr = nil;
        self.hourArr = nil;
        self.minuteArr = nil;
        self.secondArr = nil;
        self.monthWeekArr = nil;
        
        return;
    }
    if (updateDay) {
        NSString *lastSelectedDay = [self zhh_stringWithNumber:self.mSelectedDate.zhh_day];
        self.dayArr = [self zhh_dayArrayWithYear:[yearString integerValue] month:[monthString integerValue]];
        if (self.mSelectedDate) {
            if ([self.dayArr containsObject:lastSelectedDay]) {
                NSInteger dayIndex = [self.dayArr indexOfObject:lastSelectedDay];
                if (dayIndex != self.dayIndex) {
                    _isAdjustSelectRow = YES;
                    self.dayIndex = dayIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.dayIndex = ([lastSelectedDay intValue] < [self.dayArr.firstObject intValue]) ? 0 : (self.dayArr.count - 1);
            }
        }
    }
    
    // 2/1.更新 monthWeekArr
    if (updateWeekOfMonth) {
        NSString *lastWeekOfMonth = [self zhh_stringWithNumber:self.mSelectedDate.zhh_monthWeek];
        self.monthWeekArr = [self zhh_monthWeekArrayWithYear:[yearString integerValue] month:[monthString integerValue]];
        if (self.mSelectedDate) {
            if ([self.monthWeekArr containsObject:lastWeekOfMonth]) {
                NSInteger monthWeekIndex = [self.monthWeekArr indexOfObject:lastWeekOfMonth];
                if (monthWeekIndex != self.monthWeekIndex) {
                    _isAdjustSelectRow = YES;
                    self.monthWeekIndex = monthWeekIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.monthWeekIndex = ([lastWeekOfMonth intValue] < [self.monthWeekArr.firstObject intValue]) ? 0 : (self.monthWeekArr.count - 1);
            }
        }
    }
    
    // 3.更新 hourArr
    if (self.dayArr.count == 0) {
        return;
    }
    NSInteger day = [[self getDayString] integerValue];
    if (updateHour) {
        NSString *lastSelectedHour = [self zhh_stringWithNumber:self.mSelectedDate.zhh_hour];
        self.hourArr = [self zhh_hourArrayWithYear:[yearString integerValue] month:[monthString integerValue] day:day];
        if (self.mSelectedDate) {
            if ([self.hourArr containsObject:lastSelectedHour]) {
                NSInteger hourIndex = [self.hourArr indexOfObject:lastSelectedHour];
                if (hourIndex != self.hourIndex) {
                    _isAdjustSelectRow = YES;
                    self.hourIndex = hourIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.hourIndex = ([lastSelectedHour intValue] < [self.hourArr.firstObject intValue]) ? 0 : (self.hourArr.count - 1);
            }
        }
    }
    
    // 4.更新 minuteArr
    if (self.hourArr.count == 0) {
        return;
    }
    NSString *hourString = [self getHourString];
    if ((self.lastRowContent && [hourString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [hourString isEqualToString:self.firstRowContent])) {
        self.minuteArr = nil;
        self.secondArr = nil;
        
        return;
    }
    if (updateMinute) {
        NSString *lastSelectedMinute = [self zhh_stringWithNumber:self.mSelectedDate.zhh_minute];
        self.minuteArr = [self zhh_minuteArrayWithYear:[yearString integerValue] month:[monthString integerValue] day:day hour:[hourString integerValue]];
        if (self.mSelectedDate) {
            if ([self.minuteArr containsObject:lastSelectedMinute]) {
                NSInteger minuteIndex = [self.minuteArr indexOfObject:lastSelectedMinute];
                if (minuteIndex != self.minuteIndex) {
                    _isAdjustSelectRow = YES;
                    self.minuteIndex = minuteIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.minuteIndex = ([lastSelectedMinute intValue] < [self.minuteArr.firstObject intValue]) ? 0 : (self.minuteArr.count - 1);
            }
        }
    }
    
    // 5.更新 secondArr
    if (self.minuteArr.count == 0) {
        return;
    }
    NSString *minuteString = [self getMinuteString];
    if ((self.lastRowContent && [minuteString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [minuteString isEqualToString:self.firstRowContent])) {
        self.secondArr = nil;
        return;
    }
    if (updateSecond) {
        NSString *lastSelectedSecond = [self zhh_stringWithNumber:self.mSelectedDate.zhh_second];
        self.secondArr = [self zhh_secondArrayWithYear:[yearString integerValue] month:[monthString integerValue] day:day hour:[hourString integerValue] minute:[minuteString integerValue]];
        if (self.mSelectedDate) {
            if ([self.secondArr containsObject:lastSelectedSecond]) {
                NSInteger secondIndex = [self.secondArr indexOfObject:lastSelectedSecond];
                if (secondIndex != self.secondIndex) {
                    _isAdjustSelectRow = YES;
                    self.secondIndex = secondIndex;
                }
            } else {
                _isAdjustSelectRow = YES;
                self.secondIndex = ([lastSelectedSecond intValue] < [self.secondArr.firstObject intValue]) ? 0 : (self.secondArr.count - 1);
            }
        }
    }
}

#pragma mark - 滚动到指定日期的位置(更新选择的索引)
/// 滚动到指定日期的位置
/// @param selectDate 要滚动到的日期
/// @param animated 是否使用动画
/// @note 对于不同模式，只更新相关的索引，避免访问不存在的数组
- (void)scrollToSelectDate:(NSDate *)selectDate animated:(BOOL)animated {
    // 对于时分秒/时分模式，不依赖年月日数组
    if (self.pickerMode == ZHHDatePickerModeHMS || self.pickerMode == ZHHDatePickerModeHM) {
        // 只处理时间相关的索引
        NSInteger hour = selectDate.zhh_hour;
        // 如果是12小时制，hour的最小值为1；hour的最大值为12
        if (self.isTwelveHourMode) {
            if (hour < 1) {
                hour = 1;
            } else if (hour > 12) {
                hour = hour - 12;
            }
        }
        self.hourIndex = [self zhh_indexInArray:self.hourArr forObject:[self zhh_stringWithNumber:hour]];
        self.minuteIndex = [self zhh_indexInArray:self.minuteArr forObject:[self zhh_stringWithNumber:selectDate.zhh_minute]];
        if (self.pickerMode == ZHHDatePickerModeHMS) {
            self.secondIndex = [self zhh_indexInArray:self.secondArr forObject:[self zhh_stringWithNumber:selectDate.zhh_second]];
        }
    } else {
        // 其他模式需要年月日数组
        self.yearIndex = [self zhh_indexInArray:self.yearArr forObject:[self zhh_stringWithYear:selectDate.zhh_year]];
        self.monthIndex = [self zhh_indexInArray:self.monthArr forObject:[self zhh_stringWithNumber:selectDate.zhh_month]];
        self.dayIndex = [self zhh_indexInArray:self.dayArr forObject:[self zhh_stringWithNumber:selectDate.zhh_day]];
        if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
            self.hourIndex = selectDate.zhh_hour < 12 ? 0 : 1;
        } else {
            NSInteger hour = selectDate.zhh_hour;
            // 如果是12小时制，hour的最小值为1；hour的最大值为12
            if (self.isTwelveHourMode) {
                if (hour < 1) {
                    hour = 1;
                } else if (hour > 12) {
                    hour = hour - 12;
                }
            }
            self.hourIndex = [self zhh_indexInArray:self.hourArr forObject:[self zhh_stringWithNumber:hour]];
        }
        self.minuteIndex = [self zhh_indexInArray:self.minuteArr forObject:[self zhh_stringWithNumber:selectDate.zhh_minute]];
        self.secondIndex = [self zhh_indexInArray:self.secondArr forObject:[self zhh_stringWithNumber:selectDate.zhh_second]];
    }
    
    NSArray *indexArr = nil;
    if (self.pickerMode == ZHHDatePickerModeYMDHMS) {
        indexArr = @[@(self.yearIndex), @(self.monthIndex), @(self.dayIndex), @(self.hourIndex), @(self.minuteIndex), @(self.secondIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYMDHM) {
        indexArr = @[@(self.yearIndex), @(self.monthIndex), @(self.dayIndex), @(self.hourIndex), @(self.minuteIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYMDH) {
        indexArr = @[@(self.yearIndex), @(self.monthIndex), @(self.dayIndex), @(self.hourIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeMDHM) {
        indexArr = @[@(self.monthIndex), @(self.dayIndex), @(self.hourIndex), @(self.minuteIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYMD) {
        if ([self.language hasPrefix:@"zh"]) {
            indexArr = @[@(self.yearIndex), @(self.monthIndex), @(self.dayIndex)];
        } else {
            indexArr = @[@(self.dayIndex), @(self.monthIndex), @(self.yearIndex)];
        }
    } else if (self.pickerMode == ZHHDatePickerModeYM) {
        if ([self.language hasPrefix:@"zh"]) {
            indexArr = @[@(self.yearIndex), @(self.monthIndex)];
        } else {
            indexArr = @[@(self.monthIndex), @(self.yearIndex)];
        }
    } else if (self.pickerMode == ZHHDatePickerModeY) {
        indexArr = @[@(self.yearIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeMD) {
        indexArr = @[@(self.monthIndex), @(self.dayIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeHMS) {
        indexArr = @[@(self.hourIndex), @(self.minuteIndex), @(self.secondIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeHM) {
        indexArr = @[@(self.hourIndex), @(self.minuteIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeMS) {
        indexArr = @[@(self.minuteIndex), @(self.secondIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYMW) {
        indexArr = @[@(self.yearIndex), @(self.monthIndex), @(self.monthWeekIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYW) {
        indexArr = @[@(self.yearIndex), @(self.yearWeekIndex)];
    } else if (self.pickerMode == ZHHDatePickerModeYQ) {
        indexArr = @[@(self.yearIndex), @(self.quarterIndex)];
    }
    if (!indexArr || indexArr.count == 0) return;
    
    // 获取组件行数数组，用于验证索引是否有效
    NSArray<NSNumber *> *rowsArr = [self zhh_componentRows];
    
    for (NSInteger i = 0; i < indexArr.count && i < rowsArr.count; i++) {
        NSInteger rowIndex = [indexArr[i] integerValue];
        NSInteger maxRow = rowsArr[i].integerValue;
        
        // 确保行索引在有效范围内（0 到 maxRow-1）
        if (maxRow > 0) {
            rowIndex = MAX(0, MIN(rowIndex, maxRow - 1));
            [self.pickerView selectRow:rowIndex inComponent:i animated:animated];
        }
    }
}

#pragma mark - 滚动到【自定义字符串】的位置
- (void)scrollToCustomString:(BOOL)animated {
    switch (self.pickerMode) {
        case ZHHDatePickerModeYMDHMS:
        case ZHHDatePickerModeYMDHM:
        case ZHHDatePickerModeYMDH:
        case ZHHDatePickerModeYMD:
        case ZHHDatePickerModeYM:
        case ZHHDatePickerModeY:
        case ZHHDatePickerModeYMW:
        case ZHHDatePickerModeYW:
        case ZHHDatePickerModeYQ:
        {
            NSInteger yearIndex = ([self.selectedValue isEqualToString:self.lastRowContent] && self.yearArr.count > 0) ? self.yearArr.count - 1 : 0;
            NSInteger component = 0;
            if ((self.pickerMode == ZHHDatePickerModeYMD || self.pickerMode == ZHHDatePickerModeYMW) && ![self.language hasPrefix:@"zh"]) {
                component = 2;
            } else if ((self.pickerMode == ZHHDatePickerModeYM || self.pickerMode == ZHHDatePickerModeYQ) && ![self.language hasPrefix:@"zh"]) {
                component = 1;
            }
            [self.pickerView selectRow:yearIndex inComponent:component animated:animated];
        }
            break;
        case ZHHDatePickerModeMDHM:
        case ZHHDatePickerModeMD:
        {
            NSInteger monthIndex = ([self.selectedValue isEqualToString:self.lastRowContent] && self.monthArr.count > 0) ? self.monthArr.count - 1 : 0;
            [self.pickerView selectRow:monthIndex inComponent:0 animated:animated];
        }
            break;
        case ZHHDatePickerModeHMS:
        case ZHHDatePickerModeHM:
        {
            NSInteger hourIndex = ([self.selectedValue isEqualToString:self.lastRowContent] && self.hourArr.count > 0) ? self.hourArr.count - 1 : 0;
            [self.pickerView selectRow:hourIndex inComponent:0 animated:animated];
        }
            break;
        case ZHHDatePickerModeMS:
        {
            NSInteger minuteIndex = ([self.selectedValue isEqualToString:self.lastRowContent] && self.minuteArr.count > 0) ? self.minuteArr.count - 1 : 0;
            [self.pickerView selectRow:minuteIndex inComponent:0 animated:animated];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 日期选择器1

/// 懒加载系统日期选择器（UIDatePicker）
/// @return 配置好的 UIDatePicker 实例
/// @note 系统样式使用 UIDatePicker，支持国际化格式
- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        // 初始化时 frame 会在 show 方法中通过 Auto Layout 约束设置
        // 这里先设置一个临时 frame，实际布局由约束控制
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        // 禁用 autoresizing mask，使用 Auto Layout
        _datePicker.autoresizingMask = UIViewAutoresizingNone;
        // 添加滚动改变值的响应事件
        [_datePicker addTarget:self action:@selector(didSelectValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

#pragma mark - 日期选择器2
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = UIColor.clearColor;
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

#pragma mark - UIPickerViewDataSource

/// 返回组件数量（即 UIPickerView 的列数）
/// @note 根据不同的选择器模式返回对应的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (self.pickerMode) {
        case ZHHDatePickerModeYMDHMS: return 6;  // 年月日时分秒
        case ZHHDatePickerModeYMDHM: return 5;   // 年月日时分
        case ZHHDatePickerModeYMDH:
        case ZHHDatePickerModeMDHM:  return 4;   // 年月日时 或 月日时分
        case ZHHDatePickerModeYMD:
        case ZHHDatePickerModeYMW:
        case ZHHDatePickerModeHMS:   return 3;   // 年月日 或 年月周 或 时分秒
        case ZHHDatePickerModeYM:
        case ZHHDatePickerModeMD:
        case ZHHDatePickerModeHM:
        case ZHHDatePickerModeMS:
        case ZHHDatePickerModeYW:
        case ZHHDatePickerModeYQ:   return 2;     // 年月 或 月日 或 时分 或 分秒 或 年周 或 年季度
        case ZHHDatePickerModeY:    return 1;     // 年
        default:                    return 0;
    }
}

/// 返回每个组件的行数
/// @param pickerView UIPickerView 实例
/// @param component 组件索引（列索引）
/// @return 该组件的行数，如果数组为空或索引无效则返回 0
/// @note 添加安全检查，防止返回无效行数导致崩溃
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray<NSNumber *> *rowsArr = [self zhh_componentRows];
    if (component >= 0 && component < rowsArr.count) {
        NSInteger rowCount = rowsArr[component].integerValue;
        // 确保返回的行数不为负数
        return MAX(0, rowCount);
    }
    return 0;
}

/// 构建各模式下的组件行数数组
- (NSArray<NSNumber *> *)zhh_componentRows {
    switch (self.pickerMode) {
        case ZHHDatePickerModeYMDHMS:
            return @[@(self.yearArr.count), @(self.monthArr.count), @(self.dayArr.count),
                     @(self.hourArr.count), @(self.minuteArr.count), @(self.secondArr.count)];

        case ZHHDatePickerModeYMDHM:
            return @[@(self.yearArr.count), @(self.monthArr.count), @(self.dayArr.count),
                     @(self.hourArr.count), @(self.minuteArr.count)];

        case ZHHDatePickerModeYMDH:
            return @[@(self.yearArr.count), @(self.monthArr.count),
                     @(self.dayArr.count), @(self.hourArr.count)];

        case ZHHDatePickerModeMDHM:
            return @[@(self.monthArr.count), @(self.dayArr.count),
                     @(self.hourArr.count), @(self.minuteArr.count)];

        case ZHHDatePickerModeYMD:
            if ([self.language hasPrefix:@"zh"]) {
                return @[@(self.yearArr.count), @(self.monthArr.count), @(self.dayArr.count)];
            } else {
                return @[@(self.dayArr.count), @(self.monthArr.count), @(self.yearArr.count)];
            }

        case ZHHDatePickerModeYM:
            if ([self.language hasPrefix:@"zh"]) {
                return @[@(self.yearArr.count), @(self.monthArr.count)];
            } else {
                return @[@(self.monthArr.count), @(self.yearArr.count)];
            }

        case ZHHDatePickerModeY:
            return @[@(self.yearArr.count)];

        case ZHHDatePickerModeMD:
            return @[@(self.monthArr.count), @(self.dayArr.count)];

        case ZHHDatePickerModeHMS:
            // 确保数组不为 nil，如果为 nil 则返回空数组的 count（0）
            return @[@(self.hourArr ? self.hourArr.count : 0), 
                     @(self.minuteArr ? self.minuteArr.count : 0), 
                     @(self.secondArr ? self.secondArr.count : 0)];

        case ZHHDatePickerModeHM:
            // 确保数组不为 nil，如果为 nil 则返回空数组的 count（0）
            return @[@(self.hourArr ? self.hourArr.count : 0), 
                     @(self.minuteArr ? self.minuteArr.count : 0)];

        case ZHHDatePickerModeMS:
            return @[@(self.minuteArr.count), @(self.secondArr.count)];

        case ZHHDatePickerModeYMW:
            return @[@(self.yearArr.count), @(self.monthArr.count), @(self.monthWeekArr.count)];

        case ZHHDatePickerModeYW:
            return @[@(self.yearArr.count), @(self.yearWeekArr.count)];

        case ZHHDatePickerModeYQ:
            return @[@(self.yearArr.count), @(self.quarterArr.count)];

        default:
            return @[];
    }
}

#pragma mark - UIPickerViewDelegate
// 3. 设置 pickerView 的显示内容
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {

    // 创建或复用 UILabel 作为每一行的显示视图
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.pickerTextFont;
        label.textColor = self.pickerTextColor;
        label.numberOfLines = self.maxTextLines;
        label.adjustsFontSizeToFitWidth = YES; // 字体自适应属性
        label.minimumScaleFactor = 0.5f;       // 最小字体缩放比例
    }
    
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
        
    // 记录选择器滚动过程中选中的列和行
    [self handlePickerViewRollingStatus:pickerView component:component];

    return label;
}

/// 记录当前正在滚动的 component 与 row，
/// 目的：在用户快速滚动并立即点击“确定”时，仍能拿到最新选中行
- (void)handlePickerViewRollingStatus:(UIPickerView *)pickerView component:(NSInteger)component {

    // 获取当前 component 选中行
    NSInteger selectedRow = [pickerView selectedRowInComponent:component];
    if (selectedRow < 0) return;                    // 容错：无效行直接返回
    // 保存正在滚动的 component 及 row
    self.rollingComponent = component;
    self.rollingRow       = selectedRow;
}

// 映射每个模式下的 selector 数组
- (NSArray<NSString *> *)selectorArrayForPickerMode:(ZHHDatePickerMode)mode {
    switch (mode) {
        case ZHHDatePickerModeYMDHMS:
            return @[@"year", @"month", @"day", @"hour", @"minute", @"second"];
        case ZHHDatePickerModeYMDHM:
            return @[@"year", @"month", @"day", @"hour", @"minute"];
        case ZHHDatePickerModeYMDH:
            return @[@"year", @"month", @"day", @"hour"];
        case ZHHDatePickerModeMDHM:
            return @[@"month", @"day", @"hour", @"minute"];
        case ZHHDatePickerModeYMD:
            return [self.language hasPrefix:@"zh"] ? @[@"year", @"month", @"day"] : @[@"day", @"month", @"year"];
        case ZHHDatePickerModeYM:
            return [self.language hasPrefix:@"zh"] ? @[@"year", @"month"] : @[@"month", @"year"];
        case ZHHDatePickerModeY:
            return @[@"year"];
        case ZHHDatePickerModeMD:
            return @[@"month", @"day"];
        case ZHHDatePickerModeHMS:
            return @[@"hour", @"minute", @"second"];
        case ZHHDatePickerModeHM:
            return @[@"hour", @"minute"];
        case ZHHDatePickerModeMS:
            return @[@"minute", @"second"];
        case ZHHDatePickerModeYMW:
            return @[@"year", @"month", @"monthWeek"];
        case ZHHDatePickerModeYW:
            return @[@"year", @"yearWeek"];
        case ZHHDatePickerModeYQ:
            return @[@"year", @"quarter"];
        default:
            return @[];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray<NSString *> *selectorArray = [self selectorArrayForPickerMode:self.pickerMode];
    if (component >= selectorArray.count) return @"";
    
    NSString *type = selectorArray[component];
    
    if ([type isEqualToString:@"year"]) {
        return [self zhh_yearTextFromArray:self.yearArr row:row];
    } else if ([type isEqualToString:@"month"]) {
        return [self zhh_monthTextFromArray:self.monthArr row:row];
    } else if ([type isEqualToString:@"day"]) {
        return [self zhh_dayTextFromArray:self.dayArr row:row selectedDate:self.mSelectedDate];
    } else if ([type isEqualToString:@"hour"]) {
        return [self zhh_hourTextFromArray:self.hourArr row:row];
    } else if ([type isEqualToString:@"minute"]) {
        return [self zhh_minuteTextFromArray:self.minuteArr row:row];
    } else if ([type isEqualToString:@"second"]) {
        return [self zhh_secondTextFromArray:self.secondArr row:row];
    } else if ([type isEqualToString:@"monthWeek"]) {
        return [self zhh_weekTextFromArray:self.monthWeekArr row:row];
    } else if ([type isEqualToString:@"yearWeek"]) {
        return [self zhh_weekTextFromArray:self.yearWeekArr row:row];
    } else if ([type isEqualToString:@"quarter"]) {
        return [self zhh_quarterTextFromArray:self.quarterArr row:row];
    }
    return @"";
}

/// 判断指定视图（递归）内部是否有正在滚动的 UIScrollView
/// @param view 需要检测的根视图
/// @return YES 表示存在拖拽或减速中的 UIScrollView
- (BOOL)isAnyScrollViewRollingInView:(UIView *)view {
    // 1.若自身就是 UIScrollView，直接判断
    if ([view isKindOfClass:UIScrollView.class]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if (scrollView.isDragging || scrollView.isDecelerating) {
            return YES;
        }
    }
    // 2.递归遍历子视图
    for (UIView *subview in view.subviews) {
        if ([self isAnyScrollViewRollingInView:subview]) {
            return YES;
        }
    }
    return NO;
}

/// 对外暴露：当前 UIPickerView 是否正在滚动
- (BOOL)isRolling {
    if (self.pickerStyle == ZHHDatePickerStyleSystem) {
        return [self isAnyScrollViewRollingInView:self.datePicker];
    } else if (self.pickerStyle == ZHHDatePickerStyleCustom) {
        return [self isAnyScrollViewRollingInView:self.pickerView];
    }
    return NO;
}

// 4.滚动 pickerView 完成，执行的回调方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *lastSelectedValue = self.mSelectedValue;
    NSDate *lastSelectedDate = self.mSelectedDate;
    if (self.pickerMode == ZHHDatePickerModeYMDHMS) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 3) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 4) {
            self.minuteIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:5];
        } else if (component == 5) {
            self.secondIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count * self.hourArr.count * self.minuteArr.count * self.secondArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            int hour = [[self getHourString] intValue];
            int minute = [[self getMinuteString] intValue];
            int second = [[self getSecondString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day hour:hour minute:minute second:second];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeYMDHM) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 3) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:4];
        } else if (component == 4) {
            self.minuteIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count * self.hourArr.count * self.minuteArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            int hour = [[self getHourString] intValue];
            int minute = [[self getMinuteString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day hour:hour minute:minute];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d", year, month, day, hour, minute];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeYMDH) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:3];
        } else if (component == 3) {
            self.hourIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count * self.hourArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            int hour = 0;
            if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
                hour = (self.hourIndex == 0 ? 0 : 12);
                self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d %@", year, month, day, [self getHourString]];
            } else {
                hour = [[self getHourString] intValue];
                self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d %02d", year, month, day, hour];
            }
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day hour:hour];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeMDHM) {
        if (component == 0) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 1) {
            self.dayIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 2) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:3];
        } else if (component == 3) {
            self.minuteIndex = row;
        }
        
        NSString *monthString = [self getMonthString];
        if (![monthString isEqualToString:self.lastRowContent] && ![monthString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count * self.hourArr.count * self.minuteArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            int hour = [[self getHourString] intValue];
            int minute = [[self getMinuteString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day hour:hour minute:minute];
            self.mSelectedValue = [NSString stringWithFormat:@"%02d-%02d %02d:%02d", month, day, hour, minute];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([monthString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([monthString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeYMD) {
        if (component == 0) {
            if ([self.language hasPrefix:@"zh"]) {
                self.yearIndex = row;
                [self reloadDateArrayWithUpdateMonth:YES updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
                [self.pickerView reloadComponent:1];
                [self.pickerView reloadComponent:2];
            } else {
                self.dayIndex = row;
            }
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
            if ([self.language hasPrefix:@"zh"]) {
                [self.pickerView reloadComponent:2];
            } else {
                [self.pickerView reloadComponent:0];
            }
        } else if (component == 2) {
            if ([self.language hasPrefix:@"zh"]) {
                self.dayIndex = row;
            } else {
                self.yearIndex = row;
                [self reloadDateArrayWithUpdateMonth:YES updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
                [self.pickerView reloadComponent:0];
                [self.pickerView reloadComponent:1];
            }
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeYM) {
        if (component == 0) {
            if ([self.language hasPrefix:@"zh"]) {
                self.yearIndex = row;
                [self reloadDateArrayWithUpdateMonth:YES updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO];
                [self.pickerView reloadComponent:1];
            } else {
                self.monthIndex = row;
            }
        } else if (component == 1) {
            if ([self.language hasPrefix:@"zh"]) {
                self.monthIndex = row;
            } else {
                self.yearIndex = row;
                [self reloadDateArrayWithUpdateMonth:YES updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO];
                [self.pickerView reloadComponent:0];
            }
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d", year, month];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    } else if (self.pickerMode == ZHHDatePickerModeY) {
        if (component == 0) {
            self.yearIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count == 0) return;
            int year = [[self getYearString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d", year];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeMD) {
        if (component == 0) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.dayIndex = row;
        }
        
        NSString *monthString = [self getMonthString];
        if (![monthString isEqualToString:self.lastRowContent] && ![monthString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.dayArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int day = [[self getDayString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month day:day];
            self.mSelectedValue = [NSString stringWithFormat:@"%02d-%02d", month, day];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([monthString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([monthString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeHMS) {
        if (component == 0) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
        } else if (component == 1) {
            self.minuteIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:2];
        } else if (component == 2) {
            self.secondIndex = row;
        }
        
        NSString *hourString = [self getHourString];
        if (![hourString isEqualToString:self.lastRowContent] && ![hourString isEqualToString:self.firstRowContent]) {
            if (self.hourArr.count * self.minuteArr.count * self.secondArr.count == 0) return;
            int hour = [[self getHourString] intValue];
            int minute = [[self getMinuteString] intValue];
            int second = [[self getSecondString] intValue];
            self.mSelectedDate = [NSDate zhh_setHour:hour minute:minute second:second];
            self.mSelectedValue = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([hourString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([hourString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
        
    } else if (self.pickerMode == ZHHDatePickerModeHM) {
        if (component == 0) {
            self.hourIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.minuteIndex = row;
        }
        
        NSString *hourString = [self getHourString];
        if (![hourString isEqualToString:self.lastRowContent] && ![hourString isEqualToString:self.firstRowContent]) {
            if (self.hourArr.count * self.minuteArr.count == 0) return;
            int hour = [[self getHourString] intValue];
            int minute = [[self getMinuteString] intValue];
            self.mSelectedDate = [NSDate zhh_setHour:hour minute:minute];
            self.mSelectedValue = [NSString stringWithFormat:@"%02d:%02d", hour, minute];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([hourString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([hourString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    } else if (self.pickerMode == ZHHDatePickerModeMS) {
        if (component == 0) {
            self.minuteIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.secondIndex = row;
        }
        
        NSString *minuteString = [self getMinuteString];
        if (![minuteString isEqualToString:self.lastRowContent] && ![minuteString isEqualToString:self.firstRowContent]) {
            if (self.minuteArr.count * self.secondArr.count == 0) return;
            int minute = [[self getMinuteString] intValue];
            int second = [[self getSecondString] intValue];
            self.mSelectedDate = [NSDate zhh_setMinute:minute second:second];
            self.mSelectedValue = [NSString stringWithFormat:@"%02d:%02d", minute, second];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([minuteString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([minuteString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    } else if (self.pickerMode == ZHHDatePickerModeYMW) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:YES updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO updateWeekOfMonth:YES updateWeekOfYear:NO updateQuarter:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO updateWeekOfMonth:YES updateWeekOfYear:NO updateQuarter:NO];
            [self.pickerView reloadComponent:2];
        } else if (component == 2) {
            self.monthWeekIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.monthWeekArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int month = [[self getMonthString] intValue];
            int week = [[self getMonthWeekString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year month:month weekOfMonth:week];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, week];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    } else if (self.pickerMode == ZHHDatePickerModeYW) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO updateWeekOfMonth:NO updateWeekOfYear:YES updateQuarter:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.yearWeekIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.monthWeekArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int week = [[self getYearWeekString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year weekOfYear:week];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d", year, week];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    } else if (self.pickerMode == ZHHDatePickerModeYQ) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDateArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO updateWeekOfMonth:NO updateWeekOfYear:NO updateQuarter:YES];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.quarterIndex = row;
        }
        
        NSString *yearString = [self getYearString];
        if (![yearString isEqualToString:self.lastRowContent] && ![yearString isEqualToString:self.firstRowContent]) {
            if (self.yearArr.count * self.monthArr.count * self.monthWeekArr.count == 0) return;
            int year = [[self getYearString] intValue];
            int quarter = [[self getQuarterString] intValue];
            self.mSelectedDate = [NSDate zhh_setYear:year quarter:quarter];
            self.mSelectedValue = [NSString stringWithFormat:@"%04d-%02d", year, quarter];
        } else {
            self.mSelectedDate = self.showToNow ? [NSDate date] : nil;
            if ([yearString isEqualToString:self.lastRowContent]) {
                self.mSelectedValue = self.lastRowContent;
            } else if ([yearString isEqualToString:self.firstRowContent]) {
                self.mSelectedValue = self.firstRowContent;
            }
        }
    }
    
    // 纠正选择日期（解决：由【自定义字符串】滚动到 其它日期时，或设置 minDate，日期联动不正确问题）
    BOOL isLastRowContent = [lastSelectedValue isEqualToString:self.lastRowContent] && ![self.mSelectedValue isEqualToString:self.lastRowContent] && ![self.mSelectedValue isEqualToString:self.firstRowContent];
    BOOL isFirstRowContent = [lastSelectedValue isEqualToString:self.firstRowContent] && ![self.mSelectedValue isEqualToString:self.lastRowContent] && ![self.mSelectedValue isEqualToString:self.firstRowContent];
    if (isLastRowContent || isFirstRowContent || _isAdjustSelectRow) {
        [self scrollToSelectDate:self.mSelectedDate animated:NO];
    }
    
    // 禁止选择日期：回滚到上次选择的日期
    if (self.nonSelectableDates && self.nonSelectableDates.count > 0 && ![self.mSelectedValue isEqualToString:self.lastRowContent] && ![self.mSelectedValue isEqualToString:self.firstRowContent]) {
        for (NSDate *date in self.nonSelectableDates) {
            if ([self zhh_compareDate:date targetDate:self.mSelectedDate dateFormat:self.dateFormat] == NSOrderedSame) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 如果当前的日期不可选择，就回滚到上次选择的日期
                    [self scrollToSelectDate:lastSelectedDate animated:YES];
                });
                // 不可选择日期的回调
                if (self.didSelectNonSelectableDateBlock) {
                    self.didSelectNonSelectableDateBlock(self.mSelectedDate, self.mSelectedValue);
                }
                self.mSelectedDate = lastSelectedDate;
                self.mSelectedValue = lastSelectedValue;
                break;
            }
        }
    }
    
    // 滚动选择时执行 changeBlock 回调
    if (self.changeBlock) {
        self.changeBlock(self.mSelectedDate, self.mSelectedValue);
    }
    
    // 滚动选择范围时执行 changeBlock 回调
    if (self.changeRangeBlock) {
        self.changeRangeBlock(self.getSelectedRangeDate.firstObject, self.getSelectedRangeDate.lastObject, self.mSelectedValue);
    }
    
    // 设置自动选择时，滚动选择时就执行 resultBlock
    if (self.isAutoSelect) {
        // 滚动完成后，执行block回调
        if (self.resultBlock) {
            self.resultBlock(self.mSelectedDate, self.mSelectedValue);
        }
        if (self.resultRangeBlock) {
            self.resultRangeBlock(self.getSelectedRangeDate.firstObject, self.getSelectedRangeDate.lastObject, self.mSelectedValue);
        }
    }
}

// 设置行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.pickerRowHeight;
}

// 设置列宽
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    NSInteger columnCount = [self numberOfComponentsInPickerView:pickerView];
    CGFloat deltaSpace = columnCount > 3 ? 5 : 10;
    CGFloat columnWidth = self.pickerView.bounds.size.width / columnCount - deltaSpace;
    if (self.columnWidth > 0 && self.columnWidth <= columnWidth) {
        return self.columnWidth;
    }
    return columnWidth;
}

#pragma mark - 日期选择器1 滚动后的响应事件
- (void)didSelectValueChanged:(UIDatePicker *)sender {
    // 读取日期：datePicker.date
    self.mSelectedDate = sender.date;
    
    if (_datePickerMode != UIDatePickerModeCountDownTimer) {
        BOOL selectLessThanMin = [self zhh_compareDate:self.mSelectedDate targetDate:self.minDate dateFormat:self.dateFormat] == NSOrderedAscending;
        BOOL selectMoreThanMax = [self zhh_compareDate:self.mSelectedDate targetDate:self.maxDate dateFormat:self.dateFormat] == NSOrderedDescending;
        if (selectLessThanMin) {
            self.mSelectedDate = self.minDate;
        }
        if (selectMoreThanMax) {
            self.mSelectedDate = self.maxDate;
        }
    }
    
    [self.datePicker setDate:self.mSelectedDate animated:YES];
    
    self.mSelectedValue = [self zhh_stringFromDate:self.mSelectedDate dateFormat:self.dateFormat];
    
    // 滚动选择时执行 changeBlock 回调
    if (self.changeBlock) {
        self.changeBlock(self.mSelectedDate, self.mSelectedValue);
    }
    
    // 滚动选择范围时执行 changeBlock 回调
    if (self.changeRangeBlock) {
        self.changeRangeBlock(self.getSelectedRangeDate.firstObject, self.getSelectedRangeDate.lastObject, self.mSelectedValue);
    }
    
    // 设置自动选择时，滚动选择时就执行 resultBlock
    if (self.isAutoSelect) {
        // 滚动完成后，执行block回调
        if (self.resultBlock) {
            self.resultBlock(self.mSelectedDate, self.mSelectedValue);
        }
        if (self.resultRangeBlock) {
            self.resultRangeBlock(self.getSelectedRangeDate.firstObject, self.getSelectedRangeDate.lastObject, self.mSelectedValue);
        }
    }
}

#pragma mark - 重写父类方法
- (void)reloadData {
    // 1.处理数据源
    [self configurePickerData];
    if (self.pickerStyle == ZHHDatePickerStyleSystem) {
        // 2.配置系统日期选择器（UIDatePicker）
        // 设置日期选择器模式
        self.datePicker.datePickerMode = _datePickerMode;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130400 // 编译时检查SDK版本，iOS SDK 13.4 以后版本的处理
        if (@available(iOS 13.4, *)) {
            // 适配 iOS14 以后 UIDatePicker 的显示样式
            // 注意：使用 Auto Layout 时，不需要手动设置 frame，约束会自动处理布局
            self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
#endif
        
        // 设置国际化 Locale
        self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:self.language];
        
        // 设置时区
        if (self.timeZone) {
            self.datePicker.timeZone = self.timeZone;
        }
        
        // 设置日历
        self.datePicker.calendar = self.calendar;
        
        // 设置日期范围限制
        if (self.minDate) {
            self.datePicker.minimumDate = self.minDate;
        }
        if (self.maxDate) {
            self.datePicker.maximumDate = self.maxDate;
        }
        
        // 设置倒计时时长（仅适用于倒计时模式）
        if (_datePickerMode == UIDatePickerModeCountDownTimer && self.countDownDuration > 0) {
            self.datePicker.countDownDuration = self.countDownDuration;
        }
        
        // 设置分钟间隔
        if (self.minuteInterval > 1) {
            self.datePicker.minuteInterval = self.minuteInterval;
        }
        
        // 3.滚动到选择的日期
        if (self.mSelectedDate) {
            [self.datePicker setDate:self.mSelectedDate animated:NO];
        }
    } else if (self.pickerStyle == ZHHDatePickerStyleCustom) {
        // 2.确保数组已正确初始化（防止 reloadAllComponents 时数组为空）
        // 对于 HMS 模式，确保时间数组不为空
        if (self.pickerMode == ZHHDatePickerModeHMS) {
            if (!self.hourArr || self.hourArr.count == 0 || 
                !self.minuteArr || self.minuteArr.count == 0 || 
                !self.secondArr || self.secondArr.count == 0) {
                // 如果数组为空，重新初始化
                NSDate *baseDate = self.mSelectedDate ?: [NSDate date];
                self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
                self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
                self.secondArr = [self zhh_secondArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour minute:baseDate.zhh_minute];
            }
        } else if (self.pickerMode == ZHHDatePickerModeHM) {
            if (!self.hourArr || self.hourArr.count == 0 || 
                !self.minuteArr || self.minuteArr.count == 0) {
                // 如果数组为空，重新初始化
                NSDate *baseDate = self.mSelectedDate ?: [NSDate date];
                self.hourArr = [self zhh_hourArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day];
                self.minuteArr = [self zhh_minuteArrayWithYear:baseDate.zhh_year month:baseDate.zhh_month day:baseDate.zhh_day hour:baseDate.zhh_hour];
            }
        }
        
        // 3.刷新选择器
        [self.pickerView reloadAllComponents];
        // 4.滚动到选择的日期
        if (self.selectedValue && ([self.selectedValue isEqualToString:self.lastRowContent] || [self.selectedValue isEqualToString:self.firstRowContent])) {
            [self scrollToCustomString:NO];
        } else {
            [self scrollToSelectDate:self.mSelectedDate animated:NO];
        }
    }
}

//- (void)addPickerToView:(UIView *)view {
//    _containerView = view;
//    [self setupDateFormatter:self.pickerMode];
//    // 1.添加日期选择器
//    if (self.pickerStyle == ZHHDatePickerStyleSystem) {
//        [self zhh_setupPickerView:self.datePicker toView:view];
//    } else if (self.pickerStyle == ZHHDatePickerStyleCustom) {
//        [self zhh_setupPickerView:self.pickerView toView:view];
//        if (self.unitDisplayType == ZHHDateUnitDisplayTypeOnlyCenter) {
//            // 添加日期单位到选择器
//            [self addUnitLabel];
//        }
//    }
//    
//    // ③添加中间选择行的两条分割线
////    if (self.pickerStyle.clearPickerNewStyle) {
////        [self.pickerStyle addSeparatorLineView:self.pickerView];
////    }
//    
//    // 2.绑定数据
//    [self reloadData];
//    
////    [super addPickerToView:view];
//}

/// 确认按钮点击处理
- (void)handleConfirmAction {
    if (self.isRolling) {
        NSLog(@"选择器滚动还未结束");
        // 问题：如果滚动选择器过快，然后在滚动过程中快速点击“确定”按钮，可能导致 pickerView:didSelectRow: 代理未执行，选中值不准确。
        // 解决：此处手动触发一次 pickerView:didSelectRow，确保获取最新滚动位置。
        [self pickerView:self.pickerView didSelectRow:self.rollingRow inComponent:self.rollingComponent];
    }
    
    // 执行选择结果回调
    if (self.resultBlock) {
        self.resultBlock(self.mSelectedDate, self.mSelectedValue);
    }
    if (self.resultRangeBlock) {
        self.resultRangeBlock(self.getSelectedRangeDate.firstObject, self.getSelectedRangeDate.lastObject, self.mSelectedValue);
    }
    
    // 最后执行父类的默认处理（如关闭弹窗等）
    [super handleConfirmAction];
}

#pragma mark - 添加日期单位到选择器
- (void)addUnitLabel {
    // 1. 批量移除所有单位标签
    if (self.unitLabelArr && self.unitLabelArr.count > 0) {
        [self.unitLabelArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    // 2. 清空数组
    self.unitLabelArr = nil;
    
    // 3. 重新创建并添加新单位标签
    self.unitLabelArr = [self zhh_setupUnitLabelsForPickerView:self.pickerView unitArray:self.unitArr];
}

#pragma mark - 重写父类方法
- (void)addSubViewToPicker:(UIView *)customView {
    if (self.pickerStyle == ZHHDatePickerStyleSystem) {
        [self.datePicker addSubview:customView];
    } else if (self.pickerStyle == ZHHDatePickerStyleCustom) {
        [self.pickerView addSubview:customView];
    }
}

#pragma mark - 弹出选择器视图

/// 显示日期选择器弹窗
/// @note 根据 pickerStyle 决定使用系统样式（UIDatePicker）还是自定义样式（UIPickerView）
- (void)show {
    // 1.设置日期格式和选择器样式
    [self setupDateFormatter:self.pickerMode];
    
    // 2.根据样式添加对应的选择器视图
    if (self.pickerStyle == ZHHDatePickerStyleSystem) {
        // 系统样式：使用 UIDatePicker
        [self.contentView addSubview:self.datePicker];
        self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 添加约束，使 datePicker 四边紧贴 contentView（排除 header）
        // 底部留出安全区域空间（适配 iPhone X 等带底部安全区域的设备）
        CGFloat bottomConstant = 0;
        if (@available(iOS 11.0, *)) {
            bottomConstant = -self.safeAreaInsets.bottom;
        }
        [NSLayoutConstraint activateConstraints:@[
            [self.datePicker.topAnchor constraintEqualToAnchor:self.pickerHeaderView.bottomAnchor],
            [self.datePicker.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomConstant],
            [self.datePicker.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [self.datePicker.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        ]];
    } else if (self.pickerStyle == ZHHDatePickerStyleCustom) {
        // 自定义样式：使用 UIPickerView
        [self.contentView addSubview:self.pickerView];
        self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 添加约束，使 pickerView 四边紧贴 contentView（排除 header）
        // 底部留出安全区域空间（适配 iPhone X 等带底部安全区域的设备）
        CGFloat bottomConstant = 0;
        if (@available(iOS 11.0, *)) {
            bottomConstant = -self.safeAreaInsets.bottom;
        }
        [NSLayoutConstraint activateConstraints:@[
            [self.pickerView.topAnchor constraintEqualToAnchor:self.pickerHeaderView.bottomAnchor],
            [self.pickerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomConstant],
            [self.pickerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [self.pickerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        ]];
        
        // 如果设置了单位显示类型为仅居中，添加日期单位标签
        if (self.unitDisplayType == ZHHDateUnitDisplayTypeOnlyCenter) {
            [self addUnitLabel];
        }
    }
    
    // 3.加载数据并刷新选择器
    [self reloadData];
    
    // 4.最后调用父类行为，执行显示动画
    [super show];
}

#pragma mark - 关闭选择器视图
- (void)dismiss {
//    [self removePickerFromView:nil];
}

#pragma mark - setter 方法
- (void)setPickerMode:(ZHHDatePickerMode)pickerMode {
    _pickerMode = pickerMode;
    // 非空，表示二次设置
    if (_datePicker || _pickerView) {
        ZHHDatePickerStyle lastStyle = self.pickerStyle;
        [self setupDateFormatter:pickerMode];
        // 系统样式 切换到 自定义样式
        if (lastStyle == ZHHDatePickerStyleSystem && self.pickerStyle == ZHHDatePickerStyleCustom) {
            [self.datePicker removeFromSuperview];
            [self zhh_setupPickerView:self.pickerView toView:_containerView];
        }
        // 自定义样式 切换到 系统样式
        if (lastStyle == ZHHDatePickerStyleCustom && self.pickerStyle == ZHHDatePickerStyleSystem) {
            [self.pickerView removeFromSuperview];
            [self zhh_setupPickerView:self.datePicker toView:_containerView];
        }
        // 刷新选择器数据
        [self reloadData];
        if (self.pickerStyle == ZHHDatePickerStyleCustom && self.unitDisplayType == ZHHDateUnitDisplayTypeOnlyCenter) {
            // 添加日期单位到选择器
            [self addUnitLabel];
        }
    }
}

- (void)setShowToNow:(BOOL)showToNow {
    _showToNow = showToNow;
    if (showToNow) {
        _maxDate = [NSDate date];
        _lastRowContent = [NSBundle zhh_localizedStringForKey:@"至今" language:self.language];
    }
}

- (void)setLastRowContent:(NSString *)lastRowContent {
    if (!_showToNow) {
        _lastRowContent = lastRowContent;
    }
}

// 支持动态设置选择的值
- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    _mSelectedDate = selectedDate;
    if (_datePicker || _pickerView) {
        // 刷新选择器数据
        [self reloadData];
    }
}

- (void)setSelectedValue:(NSString *)selectedValue {
    _selectedValue = selectedValue;
    _mSelectedValue = selectedValue;
    if (_datePicker || _pickerView) {
        // 刷新选择器数据
        [self reloadData];
    }
}

- (void)setTimeZone:(NSTimeZone *)timeZone {
    _timeZone = timeZone;
    // 同步时区设置
    [NSDate zhh_setTimeZone:timeZone];
}

#pragma mark - getter 方法
- (NSArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [NSArray array];
    }
    return _yearArr;
}

- (NSArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [NSArray array];
    }
    return _monthArr;
}

- (NSArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSArray array];
    }
    return _dayArr;
}

- (NSArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [NSArray array];
    }
    return _hourArr;
}

- (NSArray *)minuteArr {
    if (!_minuteArr) {
        _minuteArr = [NSArray array];
    }
    return _minuteArr;
}

- (NSArray *)secondArr {
    if (!_secondArr) {
        _secondArr = [NSArray array];
    }
    return _secondArr;
}

- (NSInteger)minuteInterval {
    if (_minuteInterval < 1 || _minuteInterval > 30) {
        _minuteInterval = 1;
    }
    return _minuteInterval;
}

- (NSInteger)secondInterval {
    if (_secondInterval < 1 || _secondInterval > 30) {
        _secondInterval = 1;
    }
    return _secondInterval;
}

- (NSArray *)unitArr {
    if (!_unitArr) {
        _unitArr = [NSArray array];
    }
    return _unitArr;
}

- (NSArray<UILabel *> *)unitLabelArr {
    if (!_unitLabelArr) {
        _unitLabelArr = [NSArray array];
    }
    return _unitLabelArr;
}

- (NSArray<NSString *> *)monthNames {
    if (!_monthNames) {
        _monthNames = [NSArray array];
    }
    return _monthNames;
}

/// 获取当前选中的年份字符串
/// @return 年份字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getYearString {
    // 检查数组是否为空
    if (!self.yearArr || self.yearArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.yearIndex >= 0 && self.yearIndex < self.yearArr.count) {
        index = self.yearIndex;
    }
    return [self.yearArr objectAtIndex:index];
}

/// 获取当前选中的月份字符串
/// @return 月份字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getMonthString {
    // 检查数组是否为空
    if (!self.monthArr || self.monthArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.monthIndex >= 0 && self.monthIndex < self.monthArr.count) {
        index = self.monthIndex;
    }
    return [self.monthArr objectAtIndex:index];
}

/// 获取当前选中的日期字符串
/// @return 日期字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getDayString {
    // 检查数组是否为空
    if (!self.dayArr || self.dayArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.dayIndex >= 0 && self.dayIndex < self.dayArr.count) {
        index = self.dayIndex;
    }
    return [self.dayArr objectAtIndex:index];
}

/// 获取当前选中的小时字符串
/// @return 小时字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getHourString {
    // 检查数组是否为空
    if (!self.hourArr || self.hourArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.hourIndex >= 0 && self.hourIndex < self.hourArr.count) {
        index = self.hourIndex;
    }
    return [self.hourArr objectAtIndex:index];
}

/// 获取当前选中的分钟字符串
/// @return 分钟字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getMinuteString {
    // 检查数组是否为空
    if (!self.minuteArr || self.minuteArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.minuteIndex >= 0 && self.minuteIndex < self.minuteArr.count) {
        index = self.minuteIndex;
    }
    return [self.minuteArr objectAtIndex:index];
}

/// 获取当前选中的秒钟字符串
/// @return 秒钟字符串，如果数组为空则返回 @"0"
/// @note 添加数组为空检查，防止崩溃
- (NSString *)getSecondString {
    // 检查数组是否为空
    if (!self.secondArr || self.secondArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (self.secondIndex >= 0 && self.secondIndex < self.secondArr.count) {
        index = self.secondIndex;
    }
    return [self.secondArr objectAtIndex:index];
}

- (NSString *)getMonthWeekString {
    NSInteger index = 0;
    if (self.monthWeekIndex >= 0 && self.monthWeekIndex < self.monthWeekArr.count) {
        index = self.monthWeekIndex;
    }
    return [self.monthWeekArr objectAtIndex:index];
}

- (NSString *)getYearWeekString {
    NSInteger index = 0;
    if (self.yearWeekIndex >= 0 && self.yearWeekIndex < self.yearWeekArr.count) {
        index = self.yearWeekIndex;
    }
    return [self.yearWeekArr objectAtIndex:index];
}

- (NSString *)getQuarterString {
    NSInteger index = 0;
    if (self.quarterIndex >= 0 && self.quarterIndex < self.quarterArr.count) {
        index = self.quarterIndex;
    }
    return [self.quarterArr objectAtIndex:index];
}

#pragma mark - 获取选中日期范围
- (NSArray<NSDate *> *)getSelectedRangeDate {
    NSDate *startDate, *endDate = nil;
    switch (self.pickerMode) {
        case ZHHDatePickerModeYMDHMS:
        case ZHHDatePickerModeMS:
        case ZHHDatePickerModeHMS:
        {
            endDate = self.mSelectedDate;
            startDate = self.mSelectedDate;
        }
            break;
        case ZHHDatePickerModeYMDHM:
        case ZHHDatePickerModeMDHM:
        case ZHHDatePickerModeHM:
        case ZHHDatePickerModeDateAndTime:
        case ZHHDatePickerModeTime:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            startDate = tempDate;
            endDate = [tempDate dateByAddingTimeInterval:59];
        }
            break;
        case ZHHDatePickerModeYMDH:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            startDate = tempDate;
            endDate = [tempDate dateByAddingTimeInterval:60 * 59 + 59];
        }
            break;
        case ZHHDatePickerModeMD:
        case ZHHDatePickerModeYMD:
        case ZHHDatePickerModeDate:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            startDate = tempDate;
            endDate = [[tempDate zhh_getNewDateToDays:1] dateByAddingTimeInterval:-1];
        }
            break;
        case ZHHDatePickerModeYM:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            startDate = tempDate;
            endDate = [[tempDate zhh_getNewDateToMonths:1] dateByAddingTimeInterval:-1];
        }
            break;
        case ZHHDatePickerModeY:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            startDate = tempDate;
            endDate = [[tempDate zhh_getNewDateToMonths:12] dateByAddingTimeInterval:-1];
        }
            break;
        case ZHHDatePickerModeYMW:
        case ZHHDatePickerModeYW:
        {
            NSDate *tempDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            endDate = [tempDate dateByAddingTimeInterval:-1];
            startDate = [tempDate zhh_getNewDateToDays:-7];
        }
            break;
        case ZHHDatePickerModeYQ:
        {
            startDate = [self zhh_dateFromString:self.mSelectedValue dateFormat:self.dateFormat];
            endDate = [[startDate zhh_getNewDateToMonths:3] dateByAddingTimeInterval:-1];
        }
            break;
            
        default:
            break;
    }
    
    NSMutableArray *dataArr = [NSMutableArray array];
    if (startDate)
        [dataArr addObject:startDate];
    if (endDate)
        [dataArr addObject:endDate];
    return dataArr;
}

@end
