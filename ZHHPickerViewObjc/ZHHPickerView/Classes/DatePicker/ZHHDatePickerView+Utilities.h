//
//  ZHHDatePickerView+Utilities.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDatePickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHHDatePickerView (Utilities)

#pragma mark - 日期处理

/// 最小日期
- (NSDate *)zhh_handlerMinDate:(nullable NSDate *)minDate;

/// 最大日期
- (NSDate *)zhh_handlerMaxDate:(nullable NSDate *)maxDate;

/// 默认选中的日期
- (NSDate *)zhh_handlerSelectedDate:(nullable NSDate *)selectedDate dateFormat:(NSString *)dateFormat;

#pragma mark - 日期与字符串转换

/// NSDate 转 NSString
- (NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

/// NSString 转 NSDate
- (NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat;

/// 比较两个日期大小（可以指定比较级数，即按指定格式进行比较）
- (NSComparisonResult)zhh_compareDate:(NSDate *)date targetDate:(NSDate *)targetDate dateFormat:(NSString *)dateFormat;

#pragma mark - 数据源数组构造

/// 获取年份数组
- (NSArray *)zhh_yearArray;

/// 获取‘月份’数组
- (NSArray *)zhh_monthArrayWithYear:(NSInteger)year;

/// 获取‘日’数组
- (NSArray *)zhh_dayArrayWithYear:(NSInteger)year month:(NSInteger)month;

/// 获取’小时‘数组
- (NSArray *)zhh_hourArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/// 获取‘分钟’数组
- (NSArray *)zhh_minuteArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour;

/// 获取‘秒钟’数组
- (NSArray *)zhh_secondArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

/// 获取‘月周’数组
- (NSArray *)zhh_monthWeekArrayWithYear:(NSInteger)year month:(NSInteger)month;

/// 获取年周数组
- (NSArray *)zhh_yearWeekArrayWithYear:(NSInteger)year;

/// 获取季度数组
- (NSArray *)zhh_quarterArrayWithYear:(NSInteger)year;

#pragma mark - UI 设置辅助方法

/// 添加 UIPickerView 到目标视图
- (void)zhh_setupPickerView:(UIView *)pickerView toView:(UIView *)view;

/// 设置日期单位 Label 数组
- (NSArray<UILabel *> *)zhh_setupUnitLabelsForPickerView:(UIPickerView *)pickerView unitArray:(NSArray<NSString *> *)unitArr;

#pragma mark - 文本构造

/// 根据年份生成字符串（可含前导零、单位等格式）
- (NSString *)zhh_stringWithYear:(NSInteger)year;

/// 将数字转为格式化字符串（常用于月、日、时等，如加前导零）
- (NSString *)zhh_stringWithNumber:(NSInteger)number;

/// 从年份数组中获取指定行的文本表示
- (NSString *)zhh_yearTextFromArray:(NSArray *)yearArr row:(NSInteger)row;

/// 从月份数组中获取指定行的文本表示
- (NSString *)zhh_monthTextFromArray:(NSArray *)monthArr row:(NSInteger)row;

/// 从日期数组中获取指定行的文本表示（支持“今天”高亮标记等）
- (NSString *)zhh_dayTextFromArray:(NSArray *)dayArr row:(NSInteger)row selectedDate:(NSDate *)selectedDate;

/// 从小时数组中获取指定行的文本表示
- (NSString *)zhh_hourTextFromArray:(NSArray *)hourArr row:(NSInteger)row;

/// 从分钟数组中获取指定行的文本表示
- (NSString *)zhh_minuteTextFromArray:(NSArray *)minuteArr row:(NSInteger)row;

/// 从秒钟数组中获取指定行的文本表示
- (NSString *)zhh_secondTextFromArray:(NSArray *)secondArr row:(NSInteger)row;

/// 从周数组中获取指定行的文本表示（如：第1周、第2周...）
- (NSString *)zhh_weekTextFromArray:(NSArray *)weekArr row:(NSInteger)row;

/// 从季度数组中获取指定行的文本表示（如：第一季度...）
- (NSString *)zhh_quarterTextFromArray:(NSArray *)quarterArr row:(NSInteger)row;

#pragma mark - 日期单位

/// 获取“年”的单位文本（如：“年”、“Year”）
- (NSString *)zhh_yearUnit;

/// 获取“月”的单位文本
- (NSString *)zhh_monthUnit;

/// 获取“日”的单位文本
- (NSString *)zhh_dayUnit;

/// 获取“时”的单位文本
- (NSString *)zhh_hourUnit;

/// 获取“分”的单位文本
- (NSString *)zhh_minuteUnit;

/// 获取“秒”的单位文本
- (NSString *)zhh_secondUnit;

/// 获取“周”的单位文本
- (NSString *)zhh_weekUnit;

/// 获取“季度”的单位文本
- (NSString *)zhh_quarterUnit;

#pragma mark - 工具方法

/// 获取字符串在数组中的索引
- (NSInteger)zhh_indexInArray:(NSArray *)array forObject:(NSString *)obj;

/// 上午文本
- (NSString *)zhh_amText;

/// 下午文本
- (NSString *)zhh_pmText;

@end

NS_ASSUME_NONNULL_END
