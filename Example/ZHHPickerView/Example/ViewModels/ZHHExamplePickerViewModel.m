//
//  ZHHExamplePickerViewModel.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHExamplePickerViewModel.h"
#import "ZHHExamplePickerModel.h"

@implementation ZHHExamplePickerViewModel

- (NSArray<ZHHExamplePickerModel *> *)homeSections {
    if (!_homeSections) {
        NSMutableArray *sections = [NSMutableArray array];
        
        // 1. 基础效果组
        ZHHExamplePickerModel *basicSection = [[ZHHExamplePickerModel alloc] init];
        basicSection.title = @"基础效果";
        basicSection.items = @[
            @"基础效果"
        ];
        [sections addObject:basicSection];
        
        // 2. 字符串选择器组
        ZHHExamplePickerModel *stringSection = [[ZHHExamplePickerModel alloc] init];
        stringSection.title = @"字符串选择器";
        stringSection.items = @[
            @"固定列数选择器",
            @"联动选择器",
            @"行政区划 - 单层级",
            @"行政区划（多级联动 - 含 Code）"
        ];
        [sections addObject:stringSection];
        
        // 3. 日期选择器组
        ZHHExamplePickerModel *dateSection = [[ZHHExamplePickerModel alloc] init];
        dateSection.title = @"日期选择器";
        dateSection.items = @[
            @"日期系统样式",
            @"日期自定义样式"
        ];
        [sections addObject:dateSection];
        
        _homeSections = [sections copy];
    }
    return _homeSections;
}

- (NSArray<ZHHExamplePickerModel *> *)stringSections {
    if (!_stringSections) {

        NSMutableArray *sections = [NSMutableArray array];

        ZHHExamplePickerModel *section1 = [[ZHHExamplePickerModel alloc] init];
        section1.title = @"基础效果";
        section1.items = @[@"默认效果", @"改变按钮样式", @"不显示取消按钮，隐藏分割线", @"不显示取消按钮，title靠左显示"];
        [sections addObject:section1];

        ZHHExamplePickerModel *section2 = [[ZHHExamplePickerModel alloc] init];
        section2.title = @"固定列数选择器";
        section2.items = @[@"单列选择器", @"两列选择器", @"三列选择器"];
        [sections addObject:section2];

        ZHHExamplePickerModel *section3 = [[ZHHExamplePickerModel alloc] init];
        section3.title = @"联动选择器";
        section3.items = @[@"两列联动选择器", @"三列联动选择器"];
        [sections addObject:section3];

        ZHHExamplePickerModel *section4 = [[ZHHExamplePickerModel alloc] init];
        section4.title = @"行政区划 - 单层级";
        section4.items = @[@"省级（省份、直辖市、自治区）", @"地级（城市）", @"县级（区县）", @"乡级（乡镇、街道）", @"村级（村委会、居委会）"];
        [sections addObject:section4];
        
        ZHHExamplePickerModel *section5 = [[ZHHExamplePickerModel alloc] init];
        section5.title = @"行政区划（多级联动 - 含 Code）";
        section5.items = @[@"“省份、城市” 二级联动数据", @"“省份、城市、区县” 三级联动数据", @"“省份、城市、区县、乡镇” 四级联动数据"];
        [sections addObject:section5];
        
        _stringSections = [sections copy]; // ✅ 记得赋值！
    }

    return _stringSections;
}

- (NSArray<ZHHExampleDatePickerModel *> *)dateSections {
    if (!_dateSections) {
        NSMutableArray *sections = [NSMutableArray array];

        /// 系统样式（支持国际化格式）
        ZHHExampleDatePickerModel *systemSection = [[ZHHExampleDatePickerModel alloc] init];
        systemSection.title = @"系统样式";
        systemSection.items = @[
            [self pickerItemWithText:@"年月日（UIDatePickerModeDate）" mode:ZHHDatePickerModeDate],
            [self pickerItemWithText:@"年月日 时分（UIDatePickerModeDateAndTime）" mode:ZHHDatePickerModeDateAndTime],
            [self pickerItemWithText:@"时分（UIDatePickerModeTime）" mode:ZHHDatePickerModeTime],
            [self pickerItemWithText:@"倒计时（UIDatePickerModeCountDownTimer）" mode:ZHHDatePickerModeCountDownTimer]
        ];
        [sections addObject:systemSection];

        /// 自定义样式（增强扩展支持）
        ZHHExampleDatePickerModel *customSection = [[ZHHExampleDatePickerModel alloc] init];
        customSection.title = @"自定义样式";
        customSection.items = @[
            [self pickerItemWithText:@"年月日 时分秒（yyyy-MM-dd HH:mm:ss）" mode:ZHHDatePickerModeYMDHMS],
            [self pickerItemWithText:@"年月日 时分（yyyy-MM-dd HH:mm）" mode:ZHHDatePickerModeYMDHM],
            [self pickerItemWithText:@"年月日 时（yyyy-MM-dd HH）" mode:ZHHDatePickerModeYMDH],
            [self pickerItemWithText:@"月日 时分（MM-dd HH:mm）" mode:ZHHDatePickerModeMDHM],
            [self pickerItemWithText:@"年月日（yyyy-MM-dd）" mode:ZHHDatePickerModeYMD],
            [self pickerItemWithText:@"年月（yyyy-MM）" mode:ZHHDatePickerModeYM],
            [self pickerItemWithText:@"年（yyyy）" mode:ZHHDatePickerModeY],
            [self pickerItemWithText:@"月日（MM-dd）" mode:ZHHDatePickerModeMD],
            [self pickerItemWithText:@"时分秒（HH:mm:ss）" mode:ZHHDatePickerModeHMS],
            [self pickerItemWithText:@"时分（HH:mm）" mode:ZHHDatePickerModeHM],
            [self pickerItemWithText:@"分秒（mm:ss）" mode:ZHHDatePickerModeMS],
            [self pickerItemWithText:@"年-季度（yyyy-QQ）" mode:ZHHDatePickerModeYQ],
            [self pickerItemWithText:@"年月周（yyyy-MM-ww）" mode:ZHHDatePickerModeYMW],
            [self pickerItemWithText:@"年周（yyyy-ww）" mode:ZHHDatePickerModeYW]
        ];
        [sections addObject:customSection];

        _dateSections = [sections copy];
    }
    return _dateSections;
}

- (ZHHDatePickerModel *)pickerItemWithText:(NSString *)text mode:(ZHHDatePickerMode)mode {
    ZHHDatePickerModel *model = [[ZHHDatePickerModel alloc] init];
    model.text = text;
    model.mode = mode;
    return model;
}
@end
