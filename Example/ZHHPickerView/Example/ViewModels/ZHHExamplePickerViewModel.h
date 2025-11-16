//
//  ZHHExamplePickerViewModel.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHHExamplePickerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHHExamplePickerViewModel : NSObject
/// 首页示例选择器数据
@property (nonatomic, strong) NSArray<ZHHExamplePickerModel *> *homeSections;

/// 字符串类型选择器数据
@property (nonatomic, strong) NSArray<ZHHExamplePickerModel *> *stringSections;

/// 日期类型选择器数据
@property (nonatomic, strong) NSArray<ZHHExampleDatePickerModel *> *dateSections;
@end

NS_ASSUME_NONNULL_END
