//
//  ZHHExamplePickerModel.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHHDatePickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHHExamplePickerModel : NSObject

@property (nonatomic, copy) NSString *title;                // 分组标题
@property (nonatomic, copy) NSArray<NSString *> *items;     // 分组下的选项
@property (nonatomic, assign) ZHHDatePickerMode mode; // 对应的枚举类型

@end

@interface ZHHDatePickerModel : NSObject

@property (nonatomic, copy) NSString *text;                 // picker 显示文本
@property (nonatomic, assign) ZHHDatePickerMode mode;       // 对应的枚举值

@end

@interface ZHHExampleDatePickerModel : NSObject

@property (nonatomic, copy) NSString *title;    // 分组标题
@property (nonatomic, copy) NSArray<ZHHDatePickerModel *> *items;

@end

NS_ASSUME_NONNULL_END
