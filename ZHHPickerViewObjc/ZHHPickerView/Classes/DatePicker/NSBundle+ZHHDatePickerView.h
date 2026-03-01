//
//  NSBundle+ZHHDatePickerView.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/13.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (ZHHDatePickerView)
/// 获取 ZHHPickerView.bundle
+ (instancetype)zhh_pickerBundle;

/// 获取国际化后的文本
/// @param key 代表 Localizable.strings 文件中 key-value 中的 key。
/// @param language 设置语言（可为空，为nil时将随系统的语言自动改变）
+ (NSString *)zhh_localizedStringForKey:(NSString *)key language:(NSString *)language;
@end

NS_ASSUME_NONNULL_END
