//
//  ZHHStringPickerModel.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHStringPickerModel : NSObject

/// 唯一编码，标识项的实际值（如省份编码等）
@property (nullable, nonatomic, copy) NSString *code;

/// 显示文本（用于 picker 展示）
@property (nullable, nonatomic, copy) NSString *text;

/// 子级数据（多级联动使用）
@property (nullable, nonatomic, copy) NSArray<ZHHStringPickerModel *> *children;

/// 父级编码（可选字段，用于链式定位）
@property (nullable, nonatomic, copy) NSString *parentCode;

/// 扩展字段（用于业务扩展）
@property (nullable, nonatomic, strong) id extras;

/// 当前项在 picker 中的选中位置（由外部赋值）
@property (nonatomic, assign) NSInteger index;

/// 根据字典初始化模型对象
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/// 快捷创建仅包含 index 和 text 的模型对象
+ (instancetype)modelWithIndex:(NSInteger)index text:(nullable NSString *)text;

@end

NS_ASSUME_NONNULL_END
