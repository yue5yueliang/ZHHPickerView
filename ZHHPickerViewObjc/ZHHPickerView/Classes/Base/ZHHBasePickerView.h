//
//  ZHHBasePickerView.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHHBasePickerView : UIView

#pragma mark - 公共子视图

/// 背景遮罩视图（用于点击关闭或背景虚化）
@property (nonatomic, strong) UIView *backgroundDimView;

/// 内容容器视图（包含 header 和 picker 区域）
@property (nonatomic, strong) UIView *contentView;

/// 顶部控制区域视图（包含标题、取消和确定按钮）
@property (nonatomic, strong) UIView *pickerHeaderView;

/// 顶部左侧取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

/// 顶部右侧确定按钮
@property (nonatomic, strong) UIButton *confirmButton;

/// 顶部中间标题标签
@property (nonatomic, strong) UILabel *titleLabel;

/// 顶部与 pickerView 之间的分割线视图
@property (nonatomic, strong) UIView *separatorView;

#pragma mark - 样式配置

/// 标题对齐方式（默认居中）
@property (nonatomic , assign) NSTextAlignment titleAlignment;

/// 标题左边距（仅在左对齐模式下生效），默认 15
@property (nonatomic, assign) CGFloat titleLeadingMargin;

#pragma mark - 尺寸配置

/// 选择器内容区高度，默认 230 pt
@property (nonatomic , assign) CGFloat pickerViewHeight;

/// 顶部控制区域高度，默认 44 pt
@property (nonatomic , assign) CGFloat pickerHeaderViewHeight;

/// 取消按钮左边距
@property (nonatomic, assign) CGFloat cancelButtonLeftMargin;

/// 取消按钮宽度，默认 70 pt
@property (nonatomic, assign) CGFloat cancelButtonWidth;

/// 取消按钮高度
@property (nonatomic, assign) CGFloat cancelButtonHeight;

/// 确定按钮右边距
@property (nonatomic, assign) CGFloat confirmButtonRightMargin;

/// 确定按钮宽度，默认 70 pt
@property (nonatomic, assign) CGFloat confirmButtonWidth;

/// 确定按钮高度
@property (nonatomic, assign) CGFloat confirmButtonHeight;

#pragma mark - 行为控制

/// 是否允许点击背景关闭弹窗，默认 YES
@property (nonatomic, assign) BOOL shouldDismissWhenTapBackground;

#pragma mark - 生命周期方法

/// 初始化并配置子视图结构（供子类重写使用）
- (void)setupUI;

/// 取消按钮点击事件处理（供子类复写或自定义）
- (void)handleCancelAction;

/// 确定按钮点击事件处理（供子类复写或自定义）
- (void)handleConfirmAction;

#pragma mark - 弹出控制

/// 显示弹窗
- (void)show;

/// 关闭弹窗
- (void)dismiss;

/// 显示弹窗并回调完成
- (void)showWithCompletion:(nullable void (^)(void))completion;

/// 关闭弹窗并回调完成
- (void)dismissWithCompletion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
