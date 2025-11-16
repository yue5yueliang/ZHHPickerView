//
//  ZHHDatePickerView+Utilities.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/12.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDatePickerView+Utilities.h"
#import "ZHHDatePickerView.h"
#import "NSDate+ZHHDatePickerView.h"
#import "NSBundle+ZHHDatePickerView.h"

@implementation ZHHDatePickerView (Utilities)

#pragma mark - 日期处理

/// 最小日期
- (NSDate *)zhh_handlerMinDate:(NSDate *)minDate {
    if (!minDate) {
        if (self.pickerMode == ZHHDatePickerModeMDHM) {
            minDate = [NSDate zhh_setMonth:1 day:1 hour:0 minute:0];
        } else if (self.pickerMode == ZHHDatePickerModeMD) {
            minDate = [NSDate zhh_setMonth:1 day:1];
        } else if (self.pickerMode == ZHHDatePickerModeTime || self.pickerMode == ZHHDatePickerModeCountDownTimer || self.pickerMode == ZHHDatePickerModeHM) {
            minDate = [NSDate zhh_setHour:0 minute:0];
        } else if (self.pickerMode == ZHHDatePickerModeHMS) {
            minDate = [NSDate zhh_setHour:0 minute:0 second:0];
        } else if (self.pickerMode == ZHHDatePickerModeMS) {
            minDate = [NSDate zhh_setMinute:0 second:0];
        } else {
            minDate = [NSDate distantPast]; // 遥远的过去的一个时间点
        }
    }
    
    // 如果是12小时制，hour的最小值为1
    if (self.isTwelveHourMode) {
        minDate = [minDate zhh_setTwelveHour:1];
    }
    
    return minDate;
}

/// 最大日期
- (NSDate *)zhh_handlerMaxDate:(NSDate *)maxDate {
    if (!maxDate) {
        if (self.pickerMode == ZHHDatePickerModeMDHM) {
            maxDate = [NSDate zhh_setMonth:12 day:31 hour:23 minute:59];
        } else if (self.pickerMode == ZHHDatePickerModeMD) {
            maxDate = [NSDate zhh_setMonth:12 day:31];
        } else if (self.pickerMode == ZHHDatePickerModeTime || self.pickerMode == ZHHDatePickerModeCountDownTimer || self.pickerMode == ZHHDatePickerModeHM) {
            maxDate = [NSDate zhh_setHour:23 minute:59];
        } else if (self.pickerMode == ZHHDatePickerModeHMS) {
            maxDate = [NSDate zhh_setHour:23 minute:59 second:59];
        } else if (self.pickerMode == ZHHDatePickerModeMS) {
            maxDate = [NSDate zhh_setMinute:59 second:59];
        } else {
            maxDate = [NSDate distantFuture]; // 遥远的未来的一个时间点
        }
    }
    
    // 如果是12小时制，hour的最大值为12
    if (self.isTwelveHourMode) {
        maxDate = [maxDate zhh_setTwelveHour:12];
    }
    
    return maxDate;
}

/// 默认选中的日期
- (NSDate *)zhh_handlerSelectedDate:(NSDate *)selectedDate dateFormat:(NSString *)dateFormat {
    // selectDate 优先级高于 selectValue（推荐使用 selectDate 设置默认选中的日期）
    if (!selectedDate) {
        if (self.selectedValue && self.selectedValue.length > 0) {
            if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
                NSString *firstString = [[self.selectedValue componentsSeparatedByString:@" "] firstObject];
                NSString *lastString = [[self.selectedValue componentsSeparatedByString:@" "] lastObject];
                if ([lastString isEqualToString:[self zhh_amText]]) {
                    self.selectedValue = [NSString stringWithFormat:@"%@ 00", firstString];
                }
                if ([lastString isEqualToString:[self zhh_amText]]) {
                    self.selectedValue = [NSString stringWithFormat:@"%@ 12", firstString];
                }
            }
            
            NSDate *date = nil;
            if ([self.selectedValue isEqualToString:self.lastRowContent]) {
                date = self.showToNow ? [NSDate date] : nil;
            } else if ([self.selectedValue isEqualToString:self.firstRowContent]) {
                date = nil;
            } else {
                date = [self zhh_dateFromString:self.selectedValue dateFormat:dateFormat];
                if (!date) {
                    NSLog(@"参数异常！字符串 selectValue 的正确格式是：%@", dateFormat);
                    date = [NSDate date]; // 默认值参数格式错误时，重置/忽略默认值，防止在 Release 环境下崩溃！
                }
                if (self.pickerMode == ZHHDatePickerModeMDHM) {
                    selectedDate = [NSDate zhh_setMonth:date.zhh_month day:date.zhh_day hour:date.zhh_hour minute:date.zhh_minute];
                } else if (self.pickerMode == ZHHDatePickerModeMD) {
                    selectedDate = [NSDate zhh_setMonth:date.zhh_month day:date.zhh_day];
                } else if (self.pickerMode == ZHHDatePickerModeTime || self.pickerMode == ZHHDatePickerModeCountDownTimer || self.pickerMode == ZHHDatePickerModeHM) {
                    selectedDate = [NSDate zhh_setHour:date.zhh_hour minute:date.zhh_minute];
                } else if (self.pickerMode == ZHHDatePickerModeHMS) {
                    selectedDate = [NSDate zhh_setHour:date.zhh_hour minute:date.zhh_minute second:date.zhh_second];
                } else if (self.pickerMode == ZHHDatePickerModeMS) {
                    selectedDate = [NSDate zhh_setMinute:date.zhh_minute second:date.zhh_second];
                } else {
                    selectedDate = date;
                }
            }
        } else {
            // 不设置默认日期
            if (self.pickerMode == ZHHDatePickerModeTime ||
                self.pickerMode == ZHHDatePickerModeCountDownTimer ||
                self.pickerMode == ZHHDatePickerModeHM ||
                self.pickerMode == ZHHDatePickerModeHMS ||
                self.pickerMode == ZHHDatePickerModeMS) {
                // 默认选中最小日期
                selectedDate = self.minDate;
            } else {
                if (self.minuteInterval > 1 || self.secondInterval > 1) {
                    NSDate *date = [NSDate date];
                    NSInteger minute = self.minDate.zhh_minute % self.minuteInterval == 0 ? self.minDate.zhh_minute : 0;
                    NSInteger second = self.minDate.zhh_second % self.secondInterval == 0 ? self.minDate.zhh_second : 0;
                    selectedDate = [NSDate zhh_setYear:date.zhh_year month:date.zhh_month day:date.zhh_day hour:date.zhh_hour minute:minute second:second];
                } else {
                    // 默认选中今天的日期
                    selectedDate = [NSDate date];
                }
            }
        }
    }
    
    // 判断日期是否超过边界限制
    BOOL selectLessThanMin = [self zhh_compareDate:selectedDate targetDate:self.minDate dateFormat:dateFormat] == NSOrderedAscending;
    BOOL selectMoreThanMax = [self zhh_compareDate:selectedDate targetDate:self.maxDate dateFormat:dateFormat] == NSOrderedDescending;
    if (selectLessThanMin) {
        NSLog(@"默认选择的日期不能小于最小日期！");
        selectedDate = self.minDate;
    }
    if (selectMoreThanMax) {
        NSLog(@"默认选择的日期不能大于最大日期！");
        selectedDate = self.maxDate;
    }
    
    return selectedDate;
}

#pragma mark - 日期与字符串转换

/// NSDate 转 NSString
- (NSString *)zhh_stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat {
    return [NSDate zhh_stringFromDate:date dateFormat:dateFormat language:self.language];
}

/// NSString 转 NSDate
- (NSDate *)zhh_dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat {
    return [NSDate zhh_dateFromString:dateString dateFormat:dateFormat language:self.language];
}

/// 比较两个日期大小（可以指定比较级数，即按指定格式进行比较）
- (NSComparisonResult)zhh_compareDate:(NSDate *)date targetDate:(NSDate *)targetDate dateFormat:(NSString *)dateFormat {
    NSString *dateString1 = [self zhh_stringFromDate:date dateFormat:dateFormat];
    NSString *dateString2 = [self zhh_stringFromDate:targetDate dateFormat:dateFormat];
    NSDate *date1 = [self zhh_dateFromString:dateString1 dateFormat:dateFormat];
    NSDate *date2 = [self zhh_dateFromString:dateString2 dateFormat:dateFormat];
    if ([date1 compare:date2] == NSOrderedDescending) {
        return 1; // 大于
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        return -1; // 小于
    } else {
        return 0; // 等于
    }
}

#pragma mark - 数据源数组构造

/// 获取年份数组
- (NSArray *)zhh_yearArray {
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = self.minDate.zhh_year; i <= self.maxDate.zhh_year; i++) {
        [tempArr addObject:[self zhh_stringWithYear:i]];
    }
    if (self.isDescending) {
        NSArray *reversedArr = [[tempArr reverseObjectEnumerator] allObjects];
        tempArr = [reversedArr mutableCopy];
    }
    // 判断是否需要添加【自定义字符串】
    if (self.lastRowContent || self.firstRowContent) {
        switch (self.pickerMode) {
            case ZHHDatePickerModeYMDHMS:
            case ZHHDatePickerModeYMDHM:
            case ZHHDatePickerModeYMDH:
            case ZHHDatePickerModeYMD:
            case ZHHDatePickerModeYM:
            case ZHHDatePickerModeY:
            {
                if (self.lastRowContent) {
                    [tempArr addObject:self.lastRowContent];
                }
                if (self.firstRowContent) {
                    [tempArr insertObject:self.firstRowContent atIndex:0];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    return [tempArr copy];
}

/// 获取‘月份’数组
- (NSArray *)zhh_monthArrayWithYear:(NSInteger)year {
    NSInteger startMonth = 1;
    NSInteger endMonth = 12;
    if (year == self.minDate.zhh_year) {
        startMonth = self.minDate.zhh_month;
    }
    if (year == self.maxDate.zhh_year) {
        endMonth = self.maxDate.zhh_month;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startMonth; i <= endMonth; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        NSArray *reversedArr = [[tempArr reverseObjectEnumerator] allObjects];
        tempArr = [reversedArr mutableCopy];
    }
    // 判断是否需要添加【自定义字符串】
    if (self.lastRowContent || self.firstRowContent) {
        switch (self.pickerMode) {
            case ZHHDatePickerModeMDHM:
            case ZHHDatePickerModeMD:
            {
                if (self.lastRowContent) {
                    [tempArr addObject:self.lastRowContent];
                }
                if (self.firstRowContent) {
                    [tempArr insertObject:self.firstRowContent atIndex:0];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    return [tempArr copy];
}

/// 获取‘日’数组
- (NSArray *)zhh_dayArrayWithYear:(NSInteger)year month:(NSInteger)month {
    NSInteger startDay = 1;
    NSInteger endDay = [NSDate zhh_getDaysInYear:year month:month];
    if (year == self.minDate.zhh_year && month == self.minDate.zhh_month) {
        startDay = self.minDate.zhh_day;
    }
    if (year == self.maxDate.zhh_year && month == self.maxDate.zhh_month) {
        endDay = self.maxDate.zhh_day;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startDay; i <= endDay; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        return [[tempArr reverseObjectEnumerator] allObjects];
    }
    
    return [tempArr copy];
}

/// 获取’小时‘数组
- (NSArray *)zhh_hourArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
        return @[[self zhh_amText], [self zhh_pmText]];
    }
    
    NSInteger startHour = self.isTwelveHourMode ? 1 : 0;
    NSInteger endHour = self.isTwelveHourMode ? 12 : 23;
    if (year == self.minDate.zhh_year && month == self.minDate.zhh_month && day == self.minDate.zhh_day) {
        startHour = self.minDate.zhh_hour;
        if (self.isTwelveHourMode) {
            if (startHour < 1 || startHour > 12) {
                startHour = 1;
            }
        }
    }
    if (year == self.maxDate.zhh_year && month == self.maxDate.zhh_month && day == self.maxDate.zhh_day) {
        endHour = self.maxDate.zhh_hour;
        if (self.isTwelveHourMode) {
            if (endHour < 1 || endHour > 12) {
                endHour = 12;
            }
        }
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startHour; i <= endHour; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        NSArray *reversedArr = [[tempArr reverseObjectEnumerator] allObjects];
        tempArr = [reversedArr mutableCopy];
    }
    // 判断是否需要添加【自定义字符串】
    if (self.lastRowContent || self.firstRowContent) {
        switch (self.pickerMode) {
            case ZHHDatePickerModeHMS:
            case ZHHDatePickerModeHM:
            {
                if (self.lastRowContent) {
                    [tempArr addObject:self.lastRowContent];
                }
                if (self.firstRowContent) {
                    [tempArr insertObject:self.firstRowContent atIndex:0];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    return [tempArr copy];
}

/// 获取‘分钟’数组
- (NSArray *)zhh_minuteArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    NSInteger startMinute = 0;
    NSInteger endMinute = 59;
    if (year == self.minDate.zhh_year && month == self.minDate.zhh_month && day == self.minDate.zhh_day && hour == self.minDate.zhh_hour) {
        startMinute = self.minDate.zhh_minute;
    }
    if (year == self.maxDate.zhh_year && month == self.maxDate.zhh_month && day == self.maxDate.zhh_day && hour == self.maxDate.zhh_hour) {
        endMinute = self.maxDate.zhh_minute;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startMinute; i <= endMinute; i += self.minuteInterval) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        NSArray *reversedArr = [[tempArr reverseObjectEnumerator] allObjects];
        tempArr = [reversedArr mutableCopy];
    }
    // 判断是否需要添加【自定义字符串】
    if (self.lastRowContent || self.firstRowContent) {
        switch (self.pickerMode) {
            case ZHHDatePickerModeMS:
            {
                if (self.lastRowContent) {
                    [tempArr addObject:self.lastRowContent];
                }
                if (self.firstRowContent) {
                    [tempArr insertObject:self.firstRowContent atIndex:0];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    return [tempArr copy];
}

/// 获取‘秒钟’数组
- (NSArray *)zhh_secondArrayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    NSInteger startSecond = 0;
    NSInteger endSecond = 59;
    if (year == self.minDate.zhh_year && month == self.minDate.zhh_month && day == self.minDate.zhh_day && hour == self.minDate.zhh_hour && minute == self.minDate.zhh_minute) {
        startSecond = self.minDate.zhh_second;
    }
    if (year == self.maxDate.zhh_year && month == self.maxDate.zhh_month && day == self.maxDate.zhh_day && hour == self.maxDate.zhh_hour && minute == self.maxDate.zhh_minute) {
        endSecond = self.maxDate.zhh_second;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startSecond; i <= endSecond; i += self.secondInterval) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        return [[tempArr reverseObjectEnumerator] allObjects];
    }
    
    return [tempArr copy];
}

/// 获取‘月周’数组
- (NSArray *)zhh_monthWeekArrayWithYear:(NSInteger)year month:(NSInteger)month {
    NSInteger startWeek = 1;
    NSInteger endWeek = [NSDate zhh_getWeeksOfMonthInYear:year month:month];
    if (year == self.minDate.zhh_year && month == self.minDate.zhh_month) {
        startWeek = self.minDate.zhh_monthWeek;
    }
    if (year == self.maxDate.zhh_year && month == self.maxDate.zhh_month) {
        endWeek = self.maxDate.zhh_monthWeek;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startWeek; i <= endWeek; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        return [[tempArr reverseObjectEnumerator] allObjects];
    }
    
    return [tempArr copy];
}

/// 获取年周数组
- (NSArray *)zhh_yearWeekArrayWithYear:(NSInteger)year {
    NSInteger startWeek = 1;
    NSInteger endWeek = [NSDate zhh_getWeeksOfYearInYear:year];
    if (year == self.minDate.zhh_year) {
        startWeek = self.minDate.zhh_yearWeek;
    }
    if (year == self.maxDate.zhh_year) {
        endWeek = self.maxDate.zhh_yearWeek;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startWeek; i <= endWeek; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        return [[tempArr reverseObjectEnumerator] allObjects];
    }
    
    return [tempArr copy];
}

/// 获取季度数组
- (NSArray *)zhh_quarterArrayWithYear:(NSInteger)year {
    NSInteger startQuarter = 1;
    NSInteger endQuarter = [NSDate zhh_getQuartersInYear:year];
    if (year == self.minDate.zhh_year) {
        startQuarter = self.minDate.zhh_quarter;
    }
    if (year == self.maxDate.zhh_year) {
        endQuarter = self.maxDate.zhh_quarter;
    }
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = startQuarter; i <= endQuarter; i++) {
        [tempArr addObject:[self zhh_stringWithNumber:i]];
    }
    if (self.isDescending) {
        return [[tempArr reverseObjectEnumerator] allObjects];
    }
    
    return [tempArr copy];
}

#pragma mark - UI 设置辅助方法

/// 添加 UIPickerView 到目标视图
- (void)zhh_setupPickerView:(UIView *)pickerView toView:(UIView *)view {
    if (view) {
        // 立即刷新容器视图 view 的布局（防止 view 使用自动布局时，选择器视图无法正常显示）
        [view setNeedsLayout];
        [view layoutIfNeeded];
        
        self.frame = view.bounds;
        CGFloat pickerHeaderViewHeight = self.pickerHeaderView ? self.pickerHeaderView.bounds.size.height : 0;
//        CGFloat pickerFooterViewHeight = self.pickerFooterView ? self.pickerFooterView.bounds.size.height : 0;
//        pickerView.frame = CGRectMake(0, pickerHeaderViewHeight, view.bounds.size.width, view.bounds.size.height - pickerHeaderViewHeight - pickerFooterViewHeight);
        pickerView.frame = CGRectMake(0, pickerHeaderViewHeight, view.bounds.size.width, view.bounds.size.height - pickerHeaderViewHeight);
        [self addSubview:pickerView];
    } else {
        // iOS16：重新设置 pickerView 高度（解决懒加载设置frame不生效问题）
//        CGFloat pickerHeaderViewHeight = self.pickerHeaderView ? self.pickerHeaderView.bounds.size.height : 0;
//        pickerView.frame = CGRectMake(0, self.pickerViewHeight + pickerHeaderViewHeight, self.keyView.bounds.size.width, self.pickerStyle.pickerHeight);
//
//        [self.alertView addSubview:pickerView];
    }
}

/// 设置日期单位 Label 数组
- (NSArray<UILabel *> *)zhh_setupUnitLabelsForPickerView:(UIPickerView *)pickerView unitArray:(NSArray<NSString *> *)unitArr {
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < pickerView.numberOfComponents; i++) {
        CGFloat componentWidth = [self pickerView:pickerView widthForComponent:i];
        // 单位label
        UILabel *unitLabel = [[UILabel alloc]init];
        unitLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        unitLabel.backgroundColor = [UIColor clearColor];
        unitLabel.font = self.dateUnitTextFont;
        unitLabel.textColor = self.dateUnitTextColor;
        // 字体自适应属性
        unitLabel.adjustsFontSizeToFitWidth = YES;
        // 自适应最小字体缩放比例
        unitLabel.minimumScaleFactor = 0.5f;
        unitLabel.text = (unitArr.count > 0 && i < unitArr.count) ? unitArr[i] : nil;
        [unitLabel sizeToFit];
        
        // 根据占位文本长度去计算lable文本宽度
        NSString *tempText = @"00";
        if (i == 0) {
            switch (self.pickerMode) {
                case ZHHDatePickerModeYMDHMS:
                case ZHHDatePickerModeYMDHM:
                case ZHHDatePickerModeYMDH:
                case ZHHDatePickerModeYMD:
                case ZHHDatePickerModeYM:
                case ZHHDatePickerModeY:
                {
                    tempText = @"0000";
                }
                    break;
                    
                default:
                    break;
            }
        }
        // 文本宽度
        CGFloat labelTextWidth = [tempText boundingRectWithSize:CGSizeMake(MAXFLOAT, self.pickerRowHeight)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:self.pickerSelectedTextFont ?: self.pickerTextFont}
                                                        context:nil].size.width;
        CGFloat margin = (pickerView.frame.size.width - componentWidth * pickerView.numberOfComponents) / 2;
        CGFloat deltaX =  (6 - pickerView.numberOfComponents) * 3 + 2;
        CGFloat centerX = margin + componentWidth / 2.0f + i * (componentWidth + 5) + labelTextWidth / 2.0f + deltaX + self.dateUnitOffsetX;
        CGFloat centerY = pickerView.frame.origin.y + pickerView.frame.size.height / 2.0f + self.dateUnitOffsetY;
        unitLabel.center = CGPointMake(centerX, centerY);
        [tempArr addObject:unitLabel];
        [pickerView.superview addSubview:unitLabel];
    }
    
    return [tempArr copy];
}

#pragma mark - 文本构造

/// 根据年份生成字符串（可含前导零、单位等格式）
- (NSString *)zhh_stringWithYear:(NSInteger)year {
    NSString *yearString = [NSString stringWithFormat:@"%@", @(year)];
    if (self.showLeadingZero) {
        yearString = [NSString stringWithFormat:@"%04d", [yearString intValue]];
    }
    return yearString;
}


/// 将数字转为格式化字符串（常用于月、日、时等，如加前导零）
- (NSString *)zhh_stringWithNumber:(NSInteger)number {
    NSString *string = [NSString stringWithFormat:@"%@", @(number)];
    if (self.showLeadingZero) {
        string = [NSString stringWithFormat:@"%02d", [string intValue]];
    }
    return string;
}

/// 从年份数组中获取指定行的文本表示
/// @param yearArr 年份数组
/// @param row 行索引
/// @return 格式化后的年份文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_yearTextFromArray:(NSArray *)yearArr row:(NSInteger)row {
    // 检查数组是否为空
    if (!yearArr || yearArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, yearArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, yearArr.count - 1));
    
    NSString *yearString = [yearArr objectAtIndex:index];
    if ((self.lastRowContent && [yearString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [yearString isEqualToString:self.firstRowContent])) {
        return yearString;
    }
    NSString *yearUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_yearUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", yearString, yearUnit];
}

/// 从月份数组中获取指定行的文本表示
/// @param monthArr 月份数组
/// @param row 行索引
/// @return 格式化后的月份文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_monthTextFromArray:(NSArray *)monthArr row:(NSInteger)row {
    // 检查数组是否为空
    if (!monthArr || monthArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, monthArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, monthArr.count - 1));
    
    NSString *monthString = [monthArr objectAtIndex:index];
    // 首行/末行是自定义字符串，直接返回
    if ((self.firstRowContent && [monthString isEqualToString:self.firstRowContent]) || (self.lastRowContent && [monthString isEqualToString:self.lastRowContent])) {
        return monthString;
    }
    
    // 自定义月份数据源
    if (self.monthNames && self.monthNames.count > 0) {
        NSInteger index = [monthString integerValue] - 1;
        monthString = (index >= 0 && index < self.monthNames.count) ? self.monthNames[index] : @"";
    } else {
        if (![self.language hasPrefix:@"zh"] && (self.pickerMode == ZHHDatePickerModeYMD || self.pickerMode == ZHHDatePickerModeYM || self.pickerMode == ZHHDatePickerModeYMW)) {
            // 非中文环境：月份使用系统的月份名称
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:self.language];
            // monthSymbols: @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
            // shortMonthSymbols: @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
            NSArray *monthNames = self.isUseShortMonthNames ? dateFormatter.shortMonthSymbols : dateFormatter.monthSymbols;
            NSInteger index = [monthString integerValue] - 1;
            monthString = (index >= 0 && index < monthNames.count) ? monthNames[index] : @"";
        } else {
            // 中文环境：月份显示数字
            NSString *monthUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_monthUnit] : @"";
            monthString = [NSString stringWithFormat:@"%@%@", monthString, monthUnit];
        }
    }
    
    return monthString;
}

/// 从日期数组中获取指定行的文本表示（支持"今天"高亮标记等）
/// @param dayArr 日期数组
/// @param row 行索引
/// @param selectedDate 选中的日期
/// @return 格式化后的日期文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_dayTextFromArray:(NSArray *)dayArr row:(NSInteger)row selectedDate:(NSDate *)selectedDate {
    // 检查数组是否为空
    if (!dayArr || dayArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, dayArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, dayArr.count - 1));
    
    NSString *dayString = [dayArr objectAtIndex:index];
    if (self.isShowToday && selectedDate.zhh_year == [NSDate date].zhh_year && selectedDate.zhh_month == [NSDate date].zhh_month && [dayString integerValue] == [NSDate date].zhh_day) {
        return [NSBundle zhh_localizedStringForKey:@"今天" language:self.language];
    }
    NSString *dayUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_dayUnit] : @"";
    dayString = [NSString stringWithFormat:@"%@%@", dayString, dayUnit];
    if (self.isShowWeek) {
        NSDate *date = [NSDate zhh_setYear:selectedDate.zhh_year month:selectedDate.zhh_month day:[dayString integerValue]];
        NSString *weekdayString = [NSBundle zhh_localizedStringForKey:[date zhh_weekdayString] language:self.language];
        dayString = [NSString stringWithFormat:@"%@%@", dayString, weekdayString];
    }
    return dayString;
}

/// 从小时数组中获取指定行的文本表示
/// @param hourArr 小时数组
/// @param row 行索引
/// @return 格式化后的小时文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_hourTextFromArray:(NSArray *)hourArr row:(NSInteger)row {
    // 检查数组是否为空
    if (!hourArr || hourArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, hourArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, hourArr.count - 1));
    
    NSString *hourString = [hourArr objectAtIndex:index];
    if ((self.lastRowContent && [hourString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [hourString isEqualToString:self.firstRowContent])) {
        return hourString;
    }
    NSString *hourUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_hourUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", hourString, hourUnit];
}

/// 从分钟数组中获取指定行的文本表示
/// @param minuteArr 分钟数组
/// @param row 行索引
/// @return 格式化后的分钟文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_minuteTextFromArray:(NSArray *)minuteArr row:(NSInteger)row {
    // 检查数组是否为空
    if (!minuteArr || minuteArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, minuteArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, minuteArr.count - 1));
    
    NSString *minuteString = [minuteArr objectAtIndex:index];
    NSString *minuteUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_minuteUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", minuteString, minuteUnit];
}

/// 从秒钟数组中获取指定行的文本表示
/// @param secondArr 秒钟数组
/// @param row 行索引
/// @return 格式化后的秒钟文本，如果数组为空则返回 @"0"
/// @note 添加空数组检查，防止崩溃
- (NSString *)zhh_secondTextFromArray:(NSArray *)secondArr row:(NSInteger)row {
    // 检查数组是否为空
    if (!secondArr || secondArr.count == 0) {
        return @"0";
    }
    
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, secondArr.count - 1);
    }
    // 确保 index 在有效范围内
    index = MAX(0, MIN(index, secondArr.count - 1));
    
    NSString *secondString = [secondArr objectAtIndex:index];
    NSString *secondUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_secondUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", secondString, secondUnit];
}

/// 从周数组中获取指定行的文本表示（如：第1周、第2周...）
- (NSString *)zhh_weekTextFromArray:(NSArray *)weekArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, weekArr.count - 1);
    }
    NSString *weekString = [weekArr objectAtIndex:index];
    if ((self.lastRowContent && [weekString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [weekString isEqualToString:self.firstRowContent])) {
        return weekString;
    }
    NSString *weekUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_weekUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", weekString, weekUnit];
}

/// 从季度数组中获取指定行的文本表示（如：第一季度...）
- (NSString *)zhh_quarterTextFromArray:(NSArray *)quarterArr row:(NSInteger)row {
    NSInteger index = 0;
    if (row >= 0) {
        index = MIN(row, quarterArr.count - 1);
    }
    NSString *quarterString = [quarterArr objectAtIndex:index];
    if ((self.lastRowContent && [quarterString isEqualToString:self.lastRowContent]) || (self.firstRowContent && [quarterString isEqualToString:self.firstRowContent])) {
        return quarterString;
    }
    NSString *quarterUnit = self.unitDisplayType == ZHHDateUnitDisplayTypeAll ? [self zhh_quarterUnit] : @"";
    return [NSString stringWithFormat:@"%@%@", quarterString, quarterUnit];
}

#pragma mark - 日期单位

/// 获取“年”的单位文本（如：“年”、“Year”）
- (NSString *)zhh_yearUnit {
    if (self.customUnit) {
        return self.customUnit[@"year"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"年" language:self.language];
}

/// 获取“月”的单位文本
- (NSString *)zhh_monthUnit {
    if (self.customUnit) {
        return self.customUnit[@"month"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"月" language:self.language];
}

/// 获取“日”的单位文本
- (NSString *)zhh_dayUnit {
    if (self.customUnit) {
        return self.customUnit[@"day"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"日" language:self.language];
}

/// 获取“时”的单位文本
- (NSString *)zhh_hourUnit {
    if (self.pickerMode == ZHHDatePickerModeYMDH && self.isShowAMAndPM) {
        return @"";
    }
    if (self.customUnit) {
        return self.customUnit[@"hour"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"时" language:self.language];
}

/// 获取“分”的单位文本
- (NSString *)zhh_minuteUnit {
    if (self.customUnit) {
        return self.customUnit[@"minute"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"分" language:self.language];
}

/// 获取“秒”的单位文本
- (NSString *)zhh_secondUnit {
    if (self.customUnit) {
        return self.customUnit[@"second"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"秒" language:self.language];
}

/// 获取“周”的单位文本
- (NSString *)zhh_weekUnit {
    if (self.customUnit) {
        return self.customUnit[@"week"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"周" language:self.language];
}

/// 获取“季度”的单位文本
- (NSString *)zhh_quarterUnit {
    if (self.customUnit) {
        return self.customUnit[@"quarter"] ? : @"";
    }
    if (![self.language hasPrefix:@"zh"]) {
        return @"";
    }
    return [NSBundle zhh_localizedStringForKey:@"季度" language:self.language];
}

#pragma mark - 工具方法

/// 获取字符串在数组中的索引
- (NSInteger)zhh_indexInArray:(NSArray *)array forObject:(NSString *)obj {
    if (!array || array.count == 0 || !obj) {
        return 0;
    }
    if ([array containsObject:obj]) {
        return [array indexOfObject:obj];
    }
    return 0;
}

/// 上午文本
- (NSString *)zhh_amText {
    return [NSBundle zhh_localizedStringForKey:@"上午" language:self.language];
}

/// 下午文本
- (NSString *)zhh_pmText {
    return [NSBundle zhh_localizedStringForKey:@"下午" language:self.language];
}
@end
