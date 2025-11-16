//
//  ZHHStringPickerModel.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHStringPickerModel.h"

@implementation ZHHStringPickerModel

/// 根据字典初始化模型对象（支持递归解析子节点）
/// @param dictionary 包含模型数据的字典，支持的 key：
///   - @"code": 唯一编码
///   - @"text": 显示文本
///   - @"parent_code": 父级编码
///   - @"extras": 扩展字段（任意类型）
///   - @"children": 子节点数组（递归解析）
/// @return 初始化后的模型对象
/// @note 如果字典格式不正确，返回空模型对象
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        // 参数合法性检查
        if (![dictionary isKindOfClass:[NSDictionary class]]) {
            return self;
        }

        // 解析基础字段（进行类型检查，确保类型安全）
        self.code = [dictionary[@"code"] isKindOfClass:[NSString class]] ? dictionary[@"code"] : nil;
        self.text = [dictionary[@"text"] isKindOfClass:[NSString class]] ? dictionary[@"text"] : nil;
        self.parentCode = [dictionary[@"parent_code"] isKindOfClass:[NSString class]] ? dictionary[@"parent_code"] : nil;
        // extras 可以是任意类型，直接赋值（可根据业务需求决定是否深拷贝）
        self.extras = dictionary[@"extras"];

        // 递归解析子节点数组
        NSArray *childrenArray = dictionary[@"children"];
        if ([childrenArray isKindOfClass:[NSArray class]] && childrenArray.count > 0) {
            NSMutableArray *childModels = [NSMutableArray arrayWithCapacity:childrenArray.count];
            for (NSDictionary *childDict in childrenArray) {
                // 只处理字典类型的子节点
                if ([childDict isKindOfClass:[NSDictionary class]]) {
                    ZHHStringPickerModel *child = [[ZHHStringPickerModel alloc] initWithDictionary:childDict];
                    [childModels addObject:child];
                }
            }
            self.children = [childModels copy];
        }
    }
    return self;
}

/// 快捷创建仅包含 index 和 text 的模型对象（工厂方法）
/// @param index 模型在列表中的索引位置
/// @param text 模型的显示文本（可为 nil）
/// @return 初始化后的模型对象
/// @note 适用于单列选择器或简单的数据模型创建
+ (instancetype)modelWithIndex:(NSInteger)index text:(nullable NSString *)text {
    ZHHStringPickerModel *model = [[ZHHStringPickerModel alloc] init];
    model.index = index;
    model.text = text;
    return model;
}

@end
