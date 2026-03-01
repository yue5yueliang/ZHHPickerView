//
//  ZHHDatePickerViewController.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/16.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDatePickerViewController.h"
#import "ZHHExamplePickerViewModel.h"
#import "ZHHExamplePickerModel.h"
#import "ZHHDatePickerView.h"

@interface ZHHDatePickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) ZHHExamplePickerViewModel *viewModel;
@property (nonatomic, strong) ZHHExampleDatePickerModel *sectionModel;

@end

@implementation ZHHDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取 section 数据
    if (self.sectionIndex >= 0 && self.sectionIndex < self.viewModel.dateSections.count) {
        self.sectionModel = self.viewModel.dateSections[self.sectionIndex];
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
    static NSString *cellIdentifier = @"DatePickerCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row < self.sectionModel.items.count) {
        ZHHDatePickerModel *item = self.sectionModel.items[indexPath.row];
        cell.textLabel.text = item.text;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 根据 section 索引处理不同的逻辑
    if (self.sectionIndex == 0) {
        // 日期系统样式
        [self handleDateSystemStyleWithItemIndex:indexPath.row];
    } else if (self.sectionIndex == 1) {
        // 日期自定义样式
        [self handleDateCustomStyleWithItemIndex:indexPath.row];
    }
}

#pragma mark - 处理各种日期选择器逻辑

/// 处理日期系统样式
- (void)handleDateSystemStyleWithItemIndex:(NSInteger)itemIndex {
    NSArray *modes = @[
        @(ZHHDatePickerModeDate),
        @(ZHHDatePickerModeDateAndTime),
        @(ZHHDatePickerModeTime),
        @(ZHHDatePickerModeCountDownTimer)
    ];
    
    if (itemIndex < modes.count) {
        ZHHDatePickerMode mode = [modes[itemIndex] integerValue];
        ZHHDatePickerView *pickerView = [[ZHHDatePickerView alloc] initWithPickerMode:mode];
        
        // 设置选中日期（示例：设置为今天）
        pickerView.selectedDate = [NSDate date];
        
        // 设置最小日期和最大日期（示例：限制在最近一年内）
        if (mode == ZHHDatePickerModeDate || mode == ZHHDatePickerModeDateAndTime) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = -18;
            pickerView.minDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
            components.year = 18;
            pickerView.maxDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
        }
        
        // 设置结果回调
        pickerView.resultBlock = ^(NSDate * _Nullable selectedDate, NSString * _Nullable selectedValue) {
            NSLog(@"✅ 日期选择结果：date = %@, value = %@", selectedDate, selectedValue);
        };
        
        [pickerView show];
    }
}

/// 处理日期自定义样式
- (void)handleDateCustomStyleWithItemIndex:(NSInteger)itemIndex {
    NSArray *modes = @[
        @(ZHHDatePickerModeYMDHMS),
        @(ZHHDatePickerModeYMDHM),
        @(ZHHDatePickerModeYMDH),
        @(ZHHDatePickerModeMDHM),
        @(ZHHDatePickerModeYMD),
        @(ZHHDatePickerModeYM),
        @(ZHHDatePickerModeY),
        @(ZHHDatePickerModeMD),
        @(ZHHDatePickerModeHMS),
        @(ZHHDatePickerModeHM),
        @(ZHHDatePickerModeMS),
        @(ZHHDatePickerModeYQ),
        @(ZHHDatePickerModeYMW),
        @(ZHHDatePickerModeYW)
    ];
    
    if (itemIndex < modes.count) {
        ZHHDatePickerMode mode = [modes[itemIndex] integerValue];
        ZHHDatePickerView *pickerView = [[ZHHDatePickerView alloc] initWithPickerMode:mode];
        
        // 设置选中日期（示例：设置为今天）
        pickerView.selectedDate = [NSDate date];
        
        // 设置最小日期和最大日期（仅对包含年、月、日的模式生效）
        if (mode == ZHHDatePickerModeYMDHMS || mode == ZHHDatePickerModeYMDHM || 
            mode == ZHHDatePickerModeYMDH || mode == ZHHDatePickerModeYMD ||
            mode == ZHHDatePickerModeYM || mode == ZHHDatePickerModeY) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.year = -18;
            pickerView.minDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
            components.year = 18;
            pickerView.maxDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
        }
        
        // 特殊配置
        if (mode == ZHHDatePickerModeYMDH) {
            pickerView.showAMAndPM = YES;
        } else if (mode == ZHHDatePickerModeMDHM) {
            pickerView.customUnit = @{@"year": @"年", @"month": @"月", @"day": @"日", @"hour": @"時", @"minute": @"分", @"second": @"秒"};
        }
        
        // 设置结果回调
        pickerView.resultBlock = ^(NSDate * _Nullable selectedDate, NSString * _Nullable selectedValue) {
            NSLog(@"✅ 日期选择结果：date = %@, value = %@", selectedDate, selectedValue);
        };
        
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
