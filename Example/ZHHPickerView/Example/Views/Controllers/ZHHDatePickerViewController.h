//
//  ZHHDatePickerViewController.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/16.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 日期选择器示例页面
@interface ZHHDatePickerViewController : UIViewController

/// Section 索引（对应 dateSections 中的索引，0-1）
@property (nonatomic, assign) NSInteger sectionIndex;

@end

NS_ASSUME_NONNULL_END

