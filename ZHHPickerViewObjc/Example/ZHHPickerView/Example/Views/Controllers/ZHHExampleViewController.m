//
//  ZHHExampleViewController.m
//  ZHHPickerView
//
//  Created by 桃色三岁 on 06/10/2025.
//  Copyright (c) 2025 桃色三岁. All rights reserved.
//

#import "ZHHExampleViewController.h"
#import "ZHHExamplePickerViewModel.h"
#import "ZHHExamplePickerModel.h"
#import "ZHHBasicEffectViewController.h"
#import "ZHHStringPickerViewController.h"
#import "ZHHDatePickerViewController.h"

@interface ZHHExampleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ZHHExamplePickerViewModel *viewModel;

@end

@implementation ZHHExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 设置导航栏标题
    self.title = @"选择器示例";
    
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

// 返回 mainTableView 中的 section 数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.homeSections.count;
}

// 返回指定 section 中的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.viewModel.homeSections.count) {
        ZHHExamplePickerModel *sectionModel = self.viewModel.homeSections[section];
        return sectionModel.items.count;
    }
    return 0;
}

/// 返回指定位置的 UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HomeCellIdentifier";
    
    // 先尝试复用已有的 cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        // 如果没有复用的，创建一个新的
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 获取 section 0 的 items，显示 item 文本
    if (indexPath.section < self.viewModel.homeSections.count) {
        ZHHExamplePickerModel *sectionModel = self.viewModel.homeSections[indexPath.section];
        if (indexPath.row < sectionModel.items.count) {
            cell.textLabel.text = sectionModel.items[indexPath.row];
        }
    }
        
    return cell;
}

// 返回 section header 标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < self.viewModel.homeSections.count) {
        ZHHExamplePickerModel *sectionModel = self.viewModel.homeSections[section];
        return sectionModel.title;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < self.viewModel.homeSections.count) {
        ZHHExamplePickerModel *sectionModel = self.viewModel.homeSections[indexPath.section];
        if (indexPath.row < sectionModel.items.count) {
            NSString *itemTitle = sectionModel.items[indexPath.row];
            
            // 根据 section 判断类型
            if (indexPath.section == 0) {
                // 基础效果组（section 0）
                ZHHBasicEffectViewController *basicVC = [[ZHHBasicEffectViewController alloc] init];
                basicVC.title = itemTitle;
                [self.navigationController pushViewController:basicVC animated:YES];
            } else if (indexPath.section == 1) {
                // 字符串选择器组（section 1）
                ZHHStringPickerViewController *stringVC = [[ZHHStringPickerViewController alloc] init];
                stringVC.sectionIndex = indexPath.row + 1; // row 0-3 对应 stringSections 的索引 1-4
                stringVC.title = itemTitle;
                [self.navigationController pushViewController:stringVC animated:YES];
            } else if (indexPath.section == 2) {
                // 日期选择器组（section 2）
                ZHHDatePickerViewController *dateVC = [[ZHHDatePickerViewController alloc] init];
                dateVC.sectionIndex = indexPath.row; // 直接使用 row 作为 sectionIndex（0-1）
                dateVC.title = itemTitle;
                [self.navigationController pushViewController:dateVC animated:YES];
            }
        }
    }
}

/// 懒加载主表视图 mainTableView
- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _mainTableView.backgroundColor = UIColor.systemGray6Color;
        _mainTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        // 设置代理
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        if (@available(iOS 15.0, *)) {
            _mainTableView.sectionHeaderTopPadding = 0;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainTableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (ZHHExamplePickerViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZHHExamplePickerViewModel alloc] init];
    }
    return _viewModel;
}

@end
