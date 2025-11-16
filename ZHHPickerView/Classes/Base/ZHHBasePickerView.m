//
//  ZHHBasePickerView.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHBasePickerView.h"

@interface ZHHBasePickerView ()

/// 标题水平居中约束（titleAlignment = center 时生效）
@property (nonatomic, strong) NSLayoutConstraint *titleCenterXConstraint;

/// 标题左边距约束（titleAlignment = left 时生效）
@property (nonatomic, strong) NSLayoutConstraint *titleLeadingConstraint;

/// 标题右边距约束（确保 title 不超出右边界）
@property (nonatomic, strong) NSLayoutConstraint *titleTrailingConstraint;


/// 顶部 header 区域高度约束（控制 pickerHeaderView 高度）
@property (nonatomic, strong) NSLayoutConstraint *pickerHeaderViewHeightConstraint;

/// 内容容器底部约束（用于动画控制弹出/隐藏）
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottomConstraint;

/// 内容容器整体高度约束（pickerHeaderView + pickerView 的总高度）
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeightConstraint;


/// 取消按钮左边距约束
@property (nonatomic, strong) NSLayoutConstraint *cancelButtonLeadingConstraint;

/// 取消按钮宽度约束
@property (nonatomic, strong) NSLayoutConstraint *cancelButtonWidthConstraint;

/// 取消按钮高度约束
@property (nonatomic, strong) NSLayoutConstraint *cancelButtonHeightConstraint;

// 确定按钮布局约束

/// 确定按钮右边距约束
@property (nonatomic, strong) NSLayoutConstraint *confirmButtonTrailingConstraint;

/// 确定按钮宽度约束
@property (nonatomic, strong) NSLayoutConstraint *confirmButtonWidthConstraint;

/// 确定按钮高度约束
@property (nonatomic, strong) NSLayoutConstraint *confirmButtonHeightConstraint;

@end

@implementation ZHHBasePickerView

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.pickerViewHeight = 230;
        self.pickerHeaderViewHeight = 44;
        self.titleLeadingMargin = 15;
        self.cancelButtonWidth = 70;
        self.confirmButtonWidth = 70;
        
        self.shouldDismissWhenTapBackground = YES;
        [self setupUI];
    }
    return self;
}

/// 初始化 UI 布局
- (void)setupUI {
    // 添加背景遮罩视图和内容视图
    [self addSubview:self.backgroundDimView];
    [self addSubview:self.contentView];

    // 添加内容子视图
    [self.contentView addSubview:self.pickerHeaderView];
    [self.pickerHeaderView addSubview:self.cancelButton];
    [self.pickerHeaderView addSubview:self.confirmButton];
    [self.pickerHeaderView addSubview:self.titleLabel];
    [self.pickerHeaderView addSubview:self.separatorView];

    // 禁用 autoresizing mask 以使用 Auto Layout
    self.backgroundDimView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pickerHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.separatorView.translatesAutoresizingMaskIntoConstraints = NO;

    // 设置 contentView 相关约束
    self.contentViewBottomConstraint = [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:self.pickerHeaderViewHeight + self.pickerViewHeight];
    self.contentViewHeightConstraint = [self.contentView.heightAnchor constraintEqualToConstant:[self totalContentViewHeight]];
    self.contentViewBottomConstraint.active = YES;

    // 设置 cancelButton 约束
    self.cancelButtonLeadingConstraint = [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.pickerHeaderView.leadingAnchor constant:0];
    self.cancelButtonWidthConstraint = [self.cancelButton.widthAnchor constraintEqualToConstant:self.cancelButtonWidth];
    self.cancelButtonHeightConstraint = [self.cancelButton.heightAnchor constraintEqualToConstant:self.pickerHeaderViewHeight];

    // 设置 confirmButton 约束
    self.confirmButtonTrailingConstraint = [self.confirmButton.trailingAnchor constraintEqualToAnchor:self.pickerHeaderView.trailingAnchor constant:0];
    self.confirmButtonWidthConstraint = [self.confirmButton.widthAnchor constraintEqualToConstant:self.confirmButtonWidth];
    self.confirmButtonHeightConstraint = [self.confirmButton.heightAnchor constraintEqualToConstant:self.pickerHeaderViewHeight];

    // 设置 titleLabel 约束（默认居中）
    self.titleCenterXConstraint = [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.pickerHeaderView.centerXAnchor];
    self.titleLeadingConstraint = [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.cancelButton.trailingAnchor constant:self.titleLeadingMargin];
    self.titleTrailingConstraint = [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.confirmButton.leadingAnchor constant:-self.titleLeadingMargin];

    // 设置 headerView 高度约束
    self.pickerHeaderViewHeightConstraint = [self.pickerHeaderView.heightAnchor constraintEqualToConstant:self.pickerHeaderViewHeight];

    // 批量激活所有约束
    [NSLayoutConstraint activateConstraints:@[
        // 背景遮罩视图铺满整个视图
        [self.backgroundDimView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.backgroundDimView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.backgroundDimView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.backgroundDimView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

        // contentView 左右贴边，底部由 contentViewBottomConstraint 控制，高度由 contentViewHeightConstraint 控制
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        self.contentViewHeightConstraint,

        // headerView 位于 contentView 顶部，左右贴边，高度由 pickerHeaderViewHeightConstraint 控制
        [self.pickerHeaderView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.pickerHeaderView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.pickerHeaderView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        self.pickerHeaderViewHeightConstraint,

        // cancelButton 布局（靠左、垂直居中）
        self.cancelButtonLeadingConstraint,
        [self.cancelButton.centerYAnchor constraintEqualToAnchor:self.pickerHeaderView.centerYAnchor],
        self.cancelButtonWidthConstraint,
        self.cancelButtonHeightConstraint,

        // confirmButton 布局（靠右、垂直居中）
        self.confirmButtonTrailingConstraint,
        [self.confirmButton.centerYAnchor constraintEqualToAnchor:self.pickerHeaderView.centerYAnchor],
        self.confirmButtonWidthConstraint,
        self.confirmButtonHeightConstraint,

        // titleLabel 布局（默认居中，左右间距由 titleLeadingConstraint / titleTrailingConstraint 控制）
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.pickerHeaderView.centerYAnchor],
        self.titleCenterXConstraint,
        self.titleTrailingConstraint,

        // 分割线 separatorView 在 headerView 底部横向铺满
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.pickerHeaderView.leadingAnchor],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.pickerHeaderView.trailingAnchor],
        [self.separatorView.bottomAnchor constraintEqualToAnchor:self.pickerHeaderView.bottomAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:0.5],
    ]];
}

/// 计算弹出视图的总高度，包括头部高度、选择器高度和底部安全区域高度
/// @return 返回 contentView 的总高度，适配不同机型的安全区域
- (CGFloat)totalContentViewHeight {
    return self.pickerHeaderViewHeight + self.pickerViewHeight + self.safeAreaInsets.bottom;
}

- (void)show {
    [self showWithCompletion:nil];
}

/// 显示弹窗并执行完成回调
/// @param completion 显示动画完成后的回调块（可为 nil）
/// @note 使用动画方式从底部滑入，同时背景遮罩逐渐显示
- (void)showWithCompletion:(nullable void (^)(void))completion {
    // 1. 将视图添加到主窗口
    UIWindow *keyWindow = [self keyWindow];
    if (!keyWindow) {
        NSLog(@"⚠️ 无法获取主窗口，弹窗显示失败");
        return;
    }
    [keyWindow addSubview:self];
    
    // 2. 立即执行一次布局，确保能正确获取 safeAreaInsets
    [self layoutIfNeeded];

    // 3. 设置初始状态：内容视图在屏幕外，背景遮罩透明
    self.contentViewHeightConstraint.constant = [self totalContentViewHeight];
    self.contentViewBottomConstraint.constant = self.pickerHeaderViewHeight + self.pickerViewHeight; // 初始位置在屏幕外
    self.backgroundDimView.alpha = 0;

    // 4. 执行显示动画
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // 内容视图滑入到屏幕底部
        self.contentViewBottomConstraint.constant = 0;
        // 背景遮罩逐渐显示
        self.backgroundDimView.alpha = 1.0;
        // 触发布局更新以执行动画
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

/// 关闭弹窗并执行完成回调
/// @param completion 关闭动画完成后的回调块（可为 nil）
/// @note 使用动画方式滑出屏幕，同时背景遮罩逐渐隐藏
- (void)dismissWithCompletion:(nullable void (^)(void))completion {
    // 计算内容视图的完整高度，用于滑出动画
    CGFloat contentHeight = CGRectGetHeight(self.contentView.frame);
    if (contentHeight <= 0) {
        // 如果高度无效，使用约束计算的高度
        contentHeight = [self totalContentViewHeight];
    }
    
    // 设置目标位置：内容视图完全移出屏幕底部
    self.contentViewBottomConstraint.constant = contentHeight;
    
    // 执行关闭动画
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // 背景遮罩逐渐隐藏
        self.backgroundDimView.alpha = 0;
        // 触发布局更新以执行滑出动画
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        // 动画完成后从父视图移除
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

// setter 实现

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment {
    _titleAlignment = titleAlignment;
    
    switch (titleAlignment) {
        case NSTextAlignmentLeft:
            self.titleCenterXConstraint.active = NO;
            self.titleLeadingConstraint.active = YES;
            self.titleTrailingConstraint.active = NO;
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
        case NSTextAlignmentCenter:
            self.titleCenterXConstraint.active = YES;
            self.titleLeadingConstraint.active = NO;
            self.titleTrailingConstraint.active = NO;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case NSTextAlignmentRight:
            self.titleCenterXConstraint.active = NO;
            self.titleLeadingConstraint.active = NO;
            self.titleTrailingConstraint.active = YES;
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            break;
        default:
            break;
    }
    
    [self.pickerHeaderView layoutIfNeeded];
}


// setter 实现
- (void)setTitleLeadingMargin:(CGFloat)titleLeadingMargin {
    _titleLeadingMargin = titleLeadingMargin;
    self.titleLeadingConstraint.constant = titleLeadingMargin;
    [self.pickerHeaderView setNeedsLayout];
}

/// 设置顶部控制区域高度
- (void)setPickerHeaderViewHeight:(CGFloat)pickerHeaderViewHeight {
    _pickerHeaderViewHeight = pickerHeaderViewHeight;
    self.pickerHeaderViewHeightConstraint.constant = pickerHeaderViewHeight;
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setCancelButtonLeftMargin:(CGFloat)cancelButtonLeftMargin {
    _cancelButtonLeftMargin = cancelButtonLeftMargin;
    self.cancelButtonLeadingConstraint.constant = cancelButtonLeftMargin;
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setCancelButtonWidth:(CGFloat)cancelButtonWidth {
    _cancelButtonWidth = cancelButtonWidth;
    self.cancelButtonWidthConstraint.constant = cancelButtonWidth;
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setCancelButtonHeight:(CGFloat)cancelButtonHeight {
    _cancelButtonHeight = cancelButtonHeight;
    self.cancelButtonHeightConstraint.constant = cancelButtonHeight;
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setConfirmButtonRightMargin:(CGFloat)confirmButtonRightMargin {
    _confirmButtonRightMargin = confirmButtonRightMargin;
    self.confirmButtonTrailingConstraint.constant = -confirmButtonRightMargin; // 负值
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setConfirmButtonWidth:(CGFloat)confirmButtonWidth {
    _confirmButtonWidth = confirmButtonWidth;
    self.confirmButtonWidthConstraint.constant = confirmButtonWidth;
    [self.pickerHeaderView setNeedsLayout];
}

- (void)setConfirmButtonHeight:(CGFloat)confirmButtonHeight {
    _confirmButtonHeight = confirmButtonHeight;
    self.confirmButtonHeightConstraint.constant = confirmButtonHeight;
    [self.pickerHeaderView setNeedsLayout];
}

#pragma mark - 半透明遮罩背景（点击关闭）

/// 懒加载背景遮罩视图
/// @return 配置好的背景遮罩视图，支持点击关闭功能
/// @note 背景色为半透明黑色（alpha=0.4），点击后根据 shouldDismissWhenTapBackground 决定是否关闭
- (UIView *)backgroundDimView {
    if (!_backgroundDimView) {
        _backgroundDimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        // 设置半透明黑色背景（40% 不透明度）
        _backgroundDimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _backgroundDimView.userInteractionEnabled = YES;

        // 添加点击手势，点击背景可关闭弹窗
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBackgroundDimView:)];
        [_backgroundDimView addGestureRecognizer:tap];
    }
    return _backgroundDimView;
}

#pragma mark - 弹出视图
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

#pragma mark - 顶部标题栏视图
- (UIView *)pickerHeaderView {
    if (!_pickerHeaderView) {
        _pickerHeaderView = [[UIView alloc] init];
    }
    return _pickerHeaderView;
}

#pragma mark - 左边取消按钮
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        [_cancelButton addTarget:self action:@selector(handleCancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - 右边确定按钮
- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        [_confirmButton addTarget:self action:@selector(handleConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - 中间标题
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = UIColor.labelColor;
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _titleLabel;
}

#pragma mark - 分割线
- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = UIColor.separatorColor;
    }
    return _separatorView;
}

#pragma mark - 点击背景遮罩图层事件

/// 处理背景遮罩的点击事件
/// @param sender 点击手势识别器
/// @note 根据 shouldDismissWhenTapBackground 属性决定是否关闭弹窗
- (void)didTapBackgroundDimView:(UITapGestureRecognizer *)sender {
    if (self.shouldDismissWhenTapBackground) {
        [self dismissWithCompletion:nil];
    }
}

#pragma mark - 取消按钮的点击事件

/// 处理取消按钮点击事件（供子类重写）
/// @note 默认行为：直接关闭弹窗，子类可重写此方法添加自定义逻辑
- (void)handleCancelAction {
    [self dismissWithCompletion:nil];
}

#pragma mark - 确定按钮的点击事件

/// 处理确定按钮点击事件（供子类重写）
/// @note 默认行为：直接关闭弹窗，子类应重写此方法处理选择结果
- (void)handleConfirmAction {
    [self dismissWithCompletion:nil];
}


#pragma mark - 获取当前应用的主窗口

/// 获取当前应用的主窗口（兼容 iOS 13+ 多场景架构）
/// @return 当前处于激活状态的主窗口，如果未找到则返回 nil
/// @note iOS 13+ 使用 UIWindowScene，需要遍历所有场景查找 keyWindow
- (UIWindow *)keyWindow {
    // iOS 13+ 多场景架构：遍历所有连接的场景
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            // 遍历场景中的所有窗口，查找处于激活状态的窗口
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return nil;
}

@end
