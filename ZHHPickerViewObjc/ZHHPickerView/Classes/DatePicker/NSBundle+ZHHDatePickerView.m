//
//  NSBundle+ZHHDatePickerView.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/13.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "NSBundle+ZHHDatePickerView.h"
#import "ZHHDatePickerView.h"

@implementation NSBundle (ZHHDatePickerView)

#pragma mark - 获取 ZHHPickerView.bundle

/// 获取 ZHHDatePickerView.bundle 资源包（单例模式，线程安全）
/// @return 资源包实例，如果未找到则返回 nil
/// @note 使用 dispatch_once 确保线程安全，避免重复查找资源包路径
+ (instancetype)zhh_pickerBundle {
    static NSBundle *pickerBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 通过类对象获取资源包所在的主 bundle
        NSBundle *bundle = [NSBundle bundleForClass:[ZHHDatePickerView class]];
        // 查找 ZHHDatePickerView.bundle 的路径
        NSString *bundlePath = [bundle pathForResource:@"ZHHDatePickerView" ofType:@"bundle"];
        if (bundlePath) {
            pickerBundle = [NSBundle bundleWithPath:bundlePath];
        }
    });
    return pickerBundle;
}

#pragma mark - 获取国际化后的文本
+ (NSString *)zhh_localizedStringForKey:(NSString *)key language:(NSString *)language {
    return [self zhh_localizedStringForKey:key value:nil language:language];
}

/// 获取国际化后的文本（内部实现）
/// @param key 本地化字符串的 key
/// @param value 默认值（如果未找到对应的本地化字符串）
/// @param language 语言标识符（如：@"zh-Hans"、@"en"），为 nil 时使用系统首选语言
/// @return 本地化后的字符串
/// @note 支持的语言：简体中文（zh-Hans）、繁体中文（zh-Hant）、英文（en）
+ (NSString *)zhh_localizedStringForKey:(NSString *)key value:(NSString *)value language:(NSString *)language {
    // 使用静态变量缓存语言包，但注意：如果语言改变需要重新加载
    // TODO: 可以考虑使用字典缓存多个语言包，key 为语言标识符
    static NSBundle *bundle = nil;
    static NSString *cachedLanguage = nil;
    
    // 如果没有手动设置语言，将随系统的语言自动改变
    if (!language) {
        // 系统首选语言
        language = [NSLocale preferredLanguages].firstObject;
    }
    
    // 标准化语言标识符
    NSString *normalizedLanguage = nil;
    if ([language hasPrefix:@"en"]) {
        normalizedLanguage = @"en";
    } else if ([language hasPrefix:@"zh"]) {
        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
            normalizedLanguage = @"zh-Hans"; // 简体中文
        } else { // zh-Hant、zh-HK、zh-TW
            normalizedLanguage = @"zh-Hant"; // 繁體中文
        }
    } else {
        normalizedLanguage = @"en"; // 默认使用英文
    }
    
    // 如果语言改变或 bundle 未加载，重新加载语言包
    if (!bundle || ![cachedLanguage isEqualToString:normalizedLanguage]) {
        NSBundle *pickerBundle = [self zhh_pickerBundle];
        if (pickerBundle) {
            NSString *lprojPath = [pickerBundle pathForResource:normalizedLanguage ofType:@"lproj"];
            bundle = [NSBundle bundleWithPath:lprojPath];
            cachedLanguage = normalizedLanguage;
        }
    }
    
    // 先从资源包中查找本地化字符串
    if (bundle) {
        value = [bundle localizedStringForKey:key value:value table:nil];
    }
    
    // 如果资源包中未找到，尝试从主 bundle 中查找（支持应用自定义覆盖）
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}


@end
