//
//  ZHHBasicEffectViewController.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/16.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHBasicEffectViewController.h"
#import "ZHHExamplePickerViewModel.h"
#import "ZHHExamplePickerModel.h"
#import "ZHHBasePickerView.h"

@interface ZHHBasicEffectViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) ZHHExamplePickerViewModel *viewModel;
@property (nonatomic, strong) ZHHExamplePickerModel *sectionModel;

@end

@implementation ZHHBasicEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取基础效果 section 数据（stringSections 的第一个）
    if (self.viewModel.stringSections.count > 0) {
        self.sectionModel = self.viewModel.stringSections[0];
    }
    
    [self.view addSubview:self.mainTableView];
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.mainTableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mainTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.mainTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionModel.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BasicEffectCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row < self.sectionModel.items.count) {
        cell.textLabel.text = self.sectionModel.items[indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 处理基础效果
    [self handleBasicEffectWithItemIndex:indexPath.row];
}

#pragma mark - 处理基础效果

/// 处理基础效果
- (void)handleBasicEffectWithItemIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        // 默认效果
        ZHHBasePickerView *pickerView = [[ZHHBasePickerView alloc] init];
        pickerView.titleLabel.text = @"Picker View标题";
        pickerView.titleLabel.backgroundColor = UIColor.cyanColor;
        pickerView.cancelButton.backgroundColor = UIColor.orangeColor;
        pickerView.confirmButton.backgroundColor = UIColor.orangeColor;
        [pickerView show];
    } else if (itemIndex == 1) {
        // 改变按钮样式
        ZHHBasePickerView *pickerView = [[ZHHBasePickerView alloc] init];
        pickerView.titleLabel.text = @"自定义Picker View高度";
        pickerView.titleLabel.backgroundColor = UIColor.cyanColor;
        pickerView.pickerViewHeight = 400;
        pickerView.pickerHeaderViewHeight = 50;
        pickerView.cancelButton.backgroundColor = UIColor.systemTealColor;
        pickerView.cancelButton.layer.cornerRadius = 5;
        pickerView.cancelButton.layer.masksToBounds = YES;
        pickerView.cancelButtonLeftMargin = 20;
        pickerView.cancelButtonWidth = 80;
        pickerView.cancelButtonHeight = 40;
        pickerView.confirmButton.backgroundColor = UIColor.systemBrownColor;
        pickerView.confirmButton.layer.cornerRadius = 5;
        pickerView.confirmButton.layer.masksToBounds = YES;
        pickerView.confirmButtonRightMargin = 20;
        pickerView.confirmButtonWidth = 80;
        pickerView.confirmButtonHeight = 40;
        [pickerView show];
    } else if (itemIndex == 2) {
        // 不显示取消按钮，隐藏分割线
        ZHHBasePickerView *pickerView = [[ZHHBasePickerView alloc] init];
        pickerView.titleLabel.backgroundColor = UIColor.cyanColor;
        pickerView.titleLabel.text = @"不显示取消按钮，隐藏分割线";
        pickerView.titleAlignment = NSTextAlignmentCenter;
        pickerView.pickerHeaderViewHeight = 50;
        pickerView.cancelButtonWidth = 0;
        pickerView.confirmButton.backgroundColor = UIColor.systemBrownColor;
        pickerView.separatorView.hidden = YES;
        [pickerView show];
    } else {
        // 不显示取消按钮，title靠左显示
        ZHHBasePickerView *pickerView = [[ZHHBasePickerView alloc] init];
        pickerView.titleLabel.backgroundColor = UIColor.cyanColor;
        pickerView.titleLabel.text = @"Picker View，标题距离左边30";
        pickerView.titleAlignment = NSTextAlignmentLeft;
        pickerView.titleLeadingMargin = 30;
        pickerView.pickerHeaderViewHeight = 50;
        pickerView.cancelButtonWidth = 0;
        pickerView.confirmButton.backgroundColor = UIColor.systemBrownColor;
        pickerView.confirmButton.layer.cornerRadius = 5;
        pickerView.confirmButton.layer.masksToBounds = YES;
        pickerView.confirmButtonRightMargin = 20;
        pickerView.confirmButtonWidth = 80;
        pickerView.confirmButtonHeight = 40;
        [pickerView show];
    }
}

#pragma mark - Lazy Loading

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _mainTableView.backgroundColor = UIColor.systemGray6Color;
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        if (@available(iOS 15.0, *)) {
            _mainTableView.sectionHeaderTopPadding = 0;
        }
    }
    return _mainTableView;
}

- (ZHHExamplePickerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZHHExamplePickerViewModel alloc] init];
    }
    return _viewModel;
}

@end
