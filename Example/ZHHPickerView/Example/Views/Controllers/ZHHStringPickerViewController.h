//
//  ZHHStringPickerViewController.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/16.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 字符串选择器示例页面
@interface ZHHStringPickerViewController : UIViewController

/// Section 索引（对应 stringSections 中的索引，0-4）
@property (nonatomic, assign) NSInteger sectionIndex;

@end

NS_ASSUME_NONNULL_END

