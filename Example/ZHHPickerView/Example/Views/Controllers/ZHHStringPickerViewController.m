//
//  ZHHStringPickerViewController.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/16.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHStringPickerViewController.h"
#import "ZHHExamplePickerViewModel.h"
#import "ZHHExamplePickerModel.h"
#import "ZHHStringPickerView.h"
#import "ZHHStringPickerModel.h"

@interface ZHHStringPickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) ZHHExamplePickerViewModel *viewModel;
@property (nonatomic, strong) ZHHExamplePickerModel *sectionModel;

@end

@implementation ZHHStringPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取 section 数据
    if (self.sectionIndex >= 0 && self.sectionIndex < self.viewModel.stringSections.count) {
        self.sectionModel = self.viewModel.stringSections[self.sectionIndex];
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
    static NSString *cellIdentifier = @"StringPickerCellIdentifier";
    
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
    
    // 根据 section 索引处理不同的逻辑
    [self handlePickerWithSectionIndex:self.sectionIndex itemIndex:indexPath.row];
}

#pragma mark - 处理各种字符串选择器逻辑

/// 根据 section 和 item 索引处理对应的选择器
- (void)handlePickerWithSectionIndex:(NSInteger)sectionIndex itemIndex:(NSInteger)itemIndex {
    if (sectionIndex == 1) {
        // 固定列数选择器
        [self handleFixedColumnPickerWithItemIndex:itemIndex];
    } else if (sectionIndex == 2) {
        // 联动选择器
        [self handleCascadePickerWithItemIndex:itemIndex];
    } else if (sectionIndex == 3) {
        // 行政区划 - 单层级
        [self handleSingleLevelRegionWithItemIndex:itemIndex];
    } else if (sectionIndex == 4) {
        // 行政区划（多级联动 - 含 Code）
        [self handleMultiLevelRegionWithItemIndex:itemIndex];
    }
}

/// 处理固定列数选择器
- (void)handleFixedColumnPickerWithItemIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        // 单列选择器
        ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeSingle];
        pickerView.dataSource = @[@"白羊座", @"金牛座", @"双子座", @"巨蟹座", @"狮子座", @"处女座", @"天秤座", @"天蝎座", @"射手座", @"摩羯座", @"水瓶座", @"双鱼座"];
        pickerView.titleLabel.text = @"选择星座";
        pickerView.pickerTextColor = UIColor.systemBlueColor;
        pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
        pickerView.pickerRowHeight = 44;
        pickerView.selectedIndex = 7;
        pickerView.singleResultBlock = ^(ZHHStringPickerModel * _Nullable model, NSInteger index) {
            if (model) {
                NSLog(@"✅ 选择结果：index = %ld，text = %@", (long)model.index, model.text);
            } else {
                NSLog(@"⚠️ 未获取到模型，仅索引 index = %ld", (long)index);
            }
        };
        [pickerView show];
    } else if (itemIndex == 1) {
        // 两列选择器
        ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeMultiple];
        pickerView.dataSource = @[
            @[@"150‑155", @"156‑160", @"161‑165", @"166‑170", @"171‑175", @"176‑180", @"181‑185", @"186‑190"],
            @[@"40‑49 kg", @"50‑59 kg", @"60‑69 kg", @"70‑79 kg", @"80‑89 kg", @"90‑99 kg"]
        ];
        pickerView.pickerTextColor = UIColor.systemBlueColor;
        pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
        pickerView.pickerRowHeight = 44;
        pickerView.columnSpacing = 16;
        pickerView.selectRowAnimated = YES;
        pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
            NSMutableString *desc = [NSMutableString string];
            [models enumerateObjectsUsingBlock:^(ZHHStringPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [desc appendFormat:@"%@(%@)  ", obj.text, indexes[idx]];
            }];
            NSLog(@"✅ 多列选择结果：%@", desc);
        };
        [pickerView show];
    } else {
        // 三列选择器
        ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeMultiple];
        pickerView.dataSource = @[
            @[@"150‑155", @"156‑160", @"161‑165", @"166‑170", @"171‑175", @"176‑180", @"181‑185", @"186‑190"],
            @[@"40‑49 kg", @"50‑59 kg", @"60‑69 kg", @"70‑79 kg", @"80‑89 kg", @"90‑99 kg"],
            @[@"A", @"B", @"AB", @"O", @"其他"]
        ];
        pickerView.pickerTextColor = UIColor.systemBlueColor;
        pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
        pickerView.pickerRowHeight = 44;
        pickerView.columnSpacing = 16;
        pickerView.selectRowAnimated = YES;
        pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
            NSMutableString *desc = [NSMutableString string];
            [models enumerateObjectsUsingBlock:^(ZHHStringPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [desc appendFormat:@"%@(%@)  ", obj.text, indexes[idx]];
            }];
            NSLog(@"✅ 多列选择结果：%@", desc);
        };
        [pickerView show];
    }
}

/// 处理联动选择器
- (void)handleCascadePickerWithItemIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        // 两列联动选择器
        ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];
        
        ZHHStringPickerModel *apple = [[ZHHStringPickerModel alloc] init];
        apple.text = @"苹果";
        apple.children = @[
            [ZHHStringPickerModel modelWithIndex:0 text:@"红富士"],
            [ZHHStringPickerModel modelWithIndex:1 text:@"青苹果"],
            [ZHHStringPickerModel modelWithIndex:2 text:@"国光"]
        ];
        
        ZHHStringPickerModel *banana = [[ZHHStringPickerModel alloc] init];
        banana.text = @"香蕉";
        banana.children = @[
            [ZHHStringPickerModel modelWithIndex:0 text:@"海南香蕉"],
            [ZHHStringPickerModel modelWithIndex:1 text:@"菲律宾香蕉"]
        ];
        
        ZHHStringPickerModel *grape = [[ZHHStringPickerModel alloc] init];
        grape.text = @"葡萄";
        grape.children = @[
            [ZHHStringPickerModel modelWithIndex:0 text:@"阳光玫瑰"],
            [ZHHStringPickerModel modelWithIndex:1 text:@"夏黑"],
            [ZHHStringPickerModel modelWithIndex:2 text:@"巨峰"]
        ];
        
        pickerView.dataSource = @[apple, banana, grape];
        pickerView.pickerTextColor = UIColor.darkGrayColor;
        pickerView.pickerTextFont = [UIFont systemFontOfSize:17];
        pickerView.pickerRowHeight = 40;
        pickerView.selectRowAnimated = YES;
        pickerView.columnSpacing = 12;
        pickerView.selectedIndexes = @[@0, @0];
        pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
            if (models.count == 2) {
                NSLog(@"✅ 联动选择结果：水果 = %@，品种 = %@", models[0].text, models[1].text);
            }
        };
        [pickerView show];
    } else {
        // 三列联动选择器
        ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];
        
        ZHHStringPickerModel *beijing = [[ZHHStringPickerModel alloc] init];
        beijing.text = @"北京市";
        beijing.children = @[({
            ZHHStringPickerModel *city = [[ZHHStringPickerModel alloc] init];
            city.text = @"北京市";
            city.children = @[
                [ZHHStringPickerModel modelWithIndex:0 text:@"朝阳区"],
                [ZHHStringPickerModel modelWithIndex:1 text:@"海淀区"],
                [ZHHStringPickerModel modelWithIndex:2 text:@"东城区"]
            ];
            city;
        })];
        
        ZHHStringPickerModel *guangdong = [[ZHHStringPickerModel alloc] init];
        guangdong.text = @"广东省";
        guangdong.children = @[
            ({
                ZHHStringPickerModel *gz = [[ZHHStringPickerModel alloc] init];
                gz.text = @"广州市";
                gz.children = @[
                    [ZHHStringPickerModel modelWithIndex:0 text:@"天河区"],
                    [ZHHStringPickerModel modelWithIndex:1 text:@"越秀区"]
                ];
                gz;
            }),
            ({
                ZHHStringPickerModel *sz = [[ZHHStringPickerModel alloc] init];
                sz.text = @"深圳市";
                sz.children = @[
                    [ZHHStringPickerModel modelWithIndex:0 text:@"南山区"],
                    [ZHHStringPickerModel modelWithIndex:1 text:@"福田区"]
                ];
                sz;
            })
        ];
        
        ZHHStringPickerModel *zhejiang = [[ZHHStringPickerModel alloc] init];
        zhejiang.text = @"浙江省";
        zhejiang.children = @[({
            ZHHStringPickerModel *hz = [[ZHHStringPickerModel alloc] init];
            hz.text = @"杭州市";
            hz.children = @[
                [ZHHStringPickerModel modelWithIndex:0 text:@"西湖区"],
                [ZHHStringPickerModel modelWithIndex:1 text:@"滨江区"]
            ];
            hz;
        })];
        
        pickerView.dataSource = @[beijing, guangdong, zhejiang];
        pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
        pickerView.pickerTextColor = UIColor.blackColor;
        pickerView.pickerRowHeight = 44;
        pickerView.columnSpacing = 10;
        pickerView.selectedIndexes = @[@1, @0, @1];
        pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
            if (models.count == 3) {
                NSLog(@"✅ 选择结果：%@ / %@ / %@", models[0].text, models[1].text, models[2].text);
            }
        };
        [pickerView show];
    }
}

/// 处理行政区划 - 单层级
- (void)handleSingleLevelRegionWithItemIndex:(NSInteger)itemIndex {
    ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];
    pickerView.pickerTextColor = UIColor.systemBlueColor;
    pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
    pickerView.pickerRowHeight = 44;
    pickerView.columnSpacing = 16;
    pickerView.selectRowAnimated = YES;
    
    NSArray *singleLevelFiles = @[
        @"provinces.json",
        @"cities.json",
        @"areas.json",
        @"streets.json",
        @"villages.json"
    ];
    if (itemIndex < singleLevelFiles.count) {
        pickerView.fileName = singleLevelFiles[itemIndex];
    }
    
    pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
        NSMutableString *desc = [NSMutableString string];
        [models enumerateObjectsUsingBlock:^(ZHHStringPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [desc appendFormat:@"%@ %@ (%@)  ", obj.text, obj.code, indexes[idx]];
        }];
        NSLog(@"✅ 多列选择结果：%@", desc);
    };
    [pickerView show];
}

/// 处理行政区划（多级联动 - 含 Code）
- (void)handleMultiLevelRegionWithItemIndex:(NSInteger)itemIndex {
    ZHHStringPickerView *pickerView = [[ZHHStringPickerView alloc] initWithPickerMode:ZHHStringPickerModeCascade];
    pickerView.pickerTextColor = UIColor.systemBlueColor;
    pickerView.pickerTextFont = [UIFont systemFontOfSize:18];
    pickerView.pickerRowHeight = 44;
    pickerView.columnSpacing = 16;
    pickerView.selectRowAnimated = YES;
    
    NSArray *multiLevelFiles = @[
        @"pc-code.json",
        @"pca-code.json",
        @"pcas-code.json"
    ];
    if (itemIndex < multiLevelFiles.count) {
        pickerView.fileName = multiLevelFiles[itemIndex];
        if (itemIndex == 1) {
            pickerView.columnSpacing = 0;
        }
    }
    
    pickerView.multiResultBlock = ^(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes) {
        NSMutableString *desc = [NSMutableString string];
        [models enumerateObjectsUsingBlock:^(ZHHStringPickerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [desc appendFormat:@"%@ %@ (%@)  ", obj.text, obj.code, indexes[idx]];
        }];
        NSLog(@"✅ 多列选择结果：%@", desc);
    };
    [pickerView show];
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
