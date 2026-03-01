//
//  ZHHStringPickerView.m
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHStringPickerView.h"

@interface ZHHStringPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

/// UIPickerView 实例，用于显示字符串数据
@property (nonatomic, strong) UIPickerView *pickerView;

/// 当前显示的数据源（支持 NSArray<NSArray<ZHHStringPickerModel *> *> 或 NSArray<ZHHStringPickerModel *>）
@property (nonatomic, copy) NSArray *dataList;

/// 当前正在滚动的列（component）
@property (nonatomic, assign) NSInteger rollingComponent;

/// 当前正在滚动的行（row）
@property (nonatomic, assign) NSInteger rollingRow;

@end

@implementation ZHHStringPickerView

#pragma mark - 初始化与数据配置

/// 初始化自定义选择器
- (instancetype)initWithPickerMode:(ZHHStringPickerMode)pickerMode {
    if (self = [super init]) {
        self.pickerMode = pickerMode;
        self.pickerTextFont = [UIFont systemFontOfSize:18.0f];
        self.pickerTextColor = [UIColor labelColor];
        self.maxTextLines = 2;
        self.pickerRowHeight = 40;
    }
    return self;
}

/// 配置选择器数据和默认选中状态
- (void)configurePickerData {
    // 1. 数据源合法性校验
    if (![self isDataSourceValid]) {
        NSLog(@"⚠️ 数据源异常！请检查选择器数据源的格式");
        return;
    }
    
    // 2. 初始化 dataList 和 selectedIndexes
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
            [self setupSinglePickerData];
            break;

        case ZHHStringPickerModeMultiple:
            [self setupMultiplePickerData];
            break;

        case ZHHStringPickerModeCascade:
            [self setupLinkagePickerData];
            break;

        default:
            break;
    }
}

/// 数据源校验
- (BOOL)isDataSourceValid {
    if (self.dataSource.count == 0) return NO;

    id firstItem = self.dataSource.firstObject;
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
            return [firstItem isKindOfClass:[NSString class]] || [firstItem isKindOfClass:[ZHHStringPickerModel class]];

        case ZHHStringPickerModeMultiple:
            return [firstItem isKindOfClass:[NSArray class]];

        case ZHHStringPickerModeCascade:
            return [firstItem isKindOfClass:[ZHHStringPickerModel class]];

        default:
            return NO;
    }
}

/// 单列模式初始化
- (void)setupSinglePickerData {
    self.dataList = self.dataSource;

    if (self.selectedIndex < 0 || self.selectedIndex >= self.dataList.count) {
        self.selectedIndex = 0;
    }
}

/// 多列模式初始化
- (void)setupMultiplePickerData {
    self.dataList = self.dataSource;

    NSMutableArray *selectedIndexes = [[NSMutableArray alloc] init];
    for (NSInteger component = 0; component < self.dataList.count; component++) {
        NSArray *componentArray = self.dataList[component];
        NSInteger selectedRow = 0;

        if (component < self.selectedIndexes.count) {
            NSInteger index = [self.selectedIndexes[component] integerValue];
            if (index >= 0 && index < componentArray.count) {
                selectedRow = index;
            }
        }

        [selectedIndexes addObject:@(selectedRow)];
    }

    self.selectedIndexes = [selectedIndexes copy];
}

/// 联动模式初始化（多级联动数据源处理）
/// @note 根据树状结构数据源，构建每级的数据列表和默认选中索引
/// @note 支持通过 showColumnNum 控制显示的列数（层级数）
- (void)setupLinkagePickerData {
    NSMutableArray *dataList = [NSMutableArray array];
    NSMutableArray *selectedIndexes = [NSMutableArray array];

    // 从第一级开始，逐级向下遍历
    NSArray *currentLevel = self.dataSource;
    NSInteger depth = 0;

    // 遍历树状结构，构建每级的数据列表
    while (currentLevel && currentLevel.count > 0) {
        // 将当前级的数据添加到列表
        [dataList addObject:currentLevel];

        // 获取当前级的默认选中索引（如果已设置）
        NSInteger selectedIndex = (depth < self.selectedIndexes.count) ? [self.selectedIndexes[depth] integerValue] : 0;
        // 确保索引在有效范围内
        selectedIndex = MIN(MAX(selectedIndex, 0), currentLevel.count - 1);
        [selectedIndexes addObject:@(selectedIndex)];

        // 获取选中项的子级数据，作为下一级的数据源
        ZHHStringPickerModel *selectedModel = currentLevel[selectedIndex];
        currentLevel = selectedModel.children;
        depth++;
    }

    // 控制固定列数显示（如果设置了 showColumnNum）
    if (self.showColumnNum > 0) {
        NSInteger currentCount = dataList.count;

        if (self.showColumnNum < currentCount) {
            // 如果设置的列数小于实际层级数，只显示前 N 级
            dataList = [[dataList subarrayWithRange:NSMakeRange(0, self.showColumnNum)] mutableCopy];
            selectedIndexes = [[selectedIndexes subarrayWithRange:NSMakeRange(0, self.showColumnNum)] mutableCopy];
        } else if (self.showColumnNum > currentCount) {
            // 如果设置的列数大于实际层级数，用空白占位补齐
            for (NSInteger i = 0; i < self.showColumnNum - currentCount; i++) {
                ZHHStringPickerModel *placeholder = [[ZHHStringPickerModel alloc] init];
                [dataList addObject:@[placeholder]];
                [selectedIndexes addObject:@(0)];
            }
        }
    }

    self.dataList = [dataList copy];
    self.selectedIndexes = [selectedIndexes copy];
}

#pragma mark - 显示与操作事件

// 子类自己的实现代码,显示pickerView
- (void)show {
    [self.contentView addSubview:self.pickerView];
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加四条约束，使 pickerView 四边紧贴 contentView
    [NSLayoutConstraint activateConstraints:@[
        [self.pickerView.topAnchor constraintEqualToAnchor:self.pickerHeaderView.bottomAnchor],
        [self.pickerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-34],
        [self.pickerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.pickerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
    ]];
    
    [self reloadData];
    // 最后调用父类行为，确保子类逻辑优先执行
    [super show];
}

/// 确认按钮点击处理
- (void)handleConfirmAction {
    if (self.isRolling) {
        NSLog(@"选择器滚动还未结束");
        // 问题：如果滚动选择器过快，然后在滚动过程中快速点击“确定”按钮，可能导致 pickerView:didSelectRow: 代理未执行，选中值不准确。
        // 解决：此处手动触发一次 pickerView:didSelectRow，确保获取最新滚动位置。
        [self pickerView:self.pickerView didSelectRow:self.rollingRow inComponent:self.rollingComponent];
    }
    
    // 2.回调选择结果
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
            if (self.singleResultBlock) {
                self.singleResultBlock([self singleSelectedModel], self.selectedIndex);
            }
            break;

        case ZHHStringPickerModeMultiple:
        case ZHHStringPickerModeCascade:
            if (self.multiResultBlock) {
                self.multiResultBlock([self multiSelectedModels], self.selectedIndexes);
            }
            break;
    }
    
    // 3.最后执行父类的默认处理（如关闭弹窗等）
    [super handleConfirmAction];
}

#pragma mark - UIPickerViewDataSource

/// 返回 UIPickerView 的组件（列）数量
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
            // 单列模式下，仅显示 1 列
            return 1;
            
        case ZHHStringPickerModeMultiple:
        case ZHHStringPickerModeCascade: {
            // 多列或联动模式下，根据数据源确定列数
            NSInteger columnCount = self.dataList.count;
            
            // 如果设置了列间距，需要在每列之间插入一个间距占位列（即空列）
            if (self.columnSpacing > 0) {
                return columnCount * 2 - 1; // 每列之间加一个间隔列
            }
            return columnCount;
        }
            
        default:
            return 0;
    }
}

/// 返回每个组件（列）对应的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
            // 单列模式，直接返回数据源数量
            return self.dataList.count;

        case ZHHStringPickerModeMultiple:
        case ZHHStringPickerModeCascade: {
            // 多列或联动模式
            if (self.columnSpacing > 0) {
                // 如果是插入的“间隔列”，返回 1 行（占位用）
                if (component % 2 == 1) {
                    return 1;
                }
                // 非间隔列，转换为真实的数据索引
                component = component / 2;
            }

            NSArray *itemList = self.dataList[component];
            return itemList.count;
        }

        default:
            return 0;
    }
}

/// 设置每行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.pickerRowHeight;
}

/// 设置每列的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    // 1.若启用了列间距并且是间隔列（奇数列），返回间距宽度
    if (self.columnSpacing > 0 && component % 2 == 1) {
        return self.columnSpacing;
    }
    
    // 2.计算实际展示列的数量（包含间距列）
    NSInteger totalComponents = [self numberOfComponentsInPickerView:pickerView];
    CGFloat totalWidth = CGRectGetWidth(self.pickerView.bounds);
    
    // 3.计算默认列宽（简单平均减去内边距）
    CGFloat estimatedWidth = totalWidth / totalComponents - 5.0;

    // 4.如果外部指定了 columnWidth，且在合理范围内，则使用指定宽度
    if (self.columnWidth > 0 && self.columnWidth <= estimatedWidth) {
        return self.columnWidth;
    }

    // 5.否则返回默认计算宽度
    return estimatedWidth;
}

#pragma mark - UIPickerViewDelegate

/// 设置每一行显示的视图内容（可自定义样式）
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {

    // 创建或复用 UILabel 作为每一行的显示视图
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.pickerTextFont;
        label.textColor = self.pickerTextColor;
        label.numberOfLines = self.maxTextLines;
        label.adjustsFontSizeToFitWidth = YES; // 字体自适应属性
        label.minimumScaleFactor = 0.5f;       // 最小字体缩放比例
    }
    
    // 记录选择器滚动过程中选中的列和行（用于回调逻辑）
    [self handlePickerViewRollingStatus:pickerView component:component];

    // 根据模式设置 label 的文本内容
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle: {
            id item = self.dataList[row];
            label.text = [item isKindOfClass:[ZHHStringPickerModel class]] ? ((ZHHStringPickerModel *)item).text : [item description];
            break;
        }
            
        case ZHHStringPickerModeMultiple:
        case ZHHStringPickerModeCascade: {
            // 如果设置了列间距，且当前是间隔列，返回空文本
            if (self.columnSpacing > 0 && component % 2 == 1) {
                label.text = @""; // 占位列不显示文本
                return label;
            }

            // 根据间距换算数据列索引
            NSInteger dataIndex = (self.columnSpacing > 0) ? component / 2 : component;
            NSArray *itemArray = self.dataList[dataIndex];
            if (row >= 0 && row < itemArray.count) {
                id item = itemArray[row];
                label.text = [item isKindOfClass:[ZHHStringPickerModel class]] ? ((ZHHStringPickerModel *)item).text : [item description];
            } else {
                label.text = @"";
            }
            break;
        }

        default:
            label.text = @"";
            break;
    }
    
    return label;
}

/// 记录当前正在滚动的 component 与 row，
/// 目的：在用户快速滚动并立即点击“确定”时，仍能拿到最新选中行
- (void)handlePickerViewRollingStatus:(UIPickerView *)pickerView component:(NSInteger)component {

    // 获取当前 component 选中行
    NSInteger selectedRow = [pickerView selectedRowInComponent:component];
    if (selectedRow < 0) return;                    // 容错：无效行直接返回
    // 保存正在滚动的 component 及 row
    self.rollingComponent = component;
    self.rollingRow       = selectedRow;
}

/// 滚动 pickerView 执行的回调方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (self.pickerMode) {
        case ZHHStringPickerModeSingle:
        {
            self.selectedIndex = row;
            // 滚动选择时执行 singleChangeBlock
            self.singleChangeBlock ? self.singleChangeBlock([self singleSelectedModel], self.selectedIndex): nil;
        }
            break;
        case ZHHStringPickerModeMultiple:
        {
            // 处理选择器有设置列间距时，选择器的滚动问题
            if (self.columnSpacing > 0) {
                if (component % 2 == 1) {
                    return;
                } else {
                    component = component / 2;
                }
            }
            
            if (component < self.selectedIndexes.count) {
                NSMutableArray *mutableArr = [self.selectedIndexes mutableCopy];
                [mutableArr replaceObjectAtIndex:component withObject:@(row)];
                self.selectedIndexes = [mutableArr copy];
            }
            
            // 滚动选择时执行 multiChangeBlock
            self.multiChangeBlock ? self.multiChangeBlock([self multiSelectedModels], self.selectedIndexes): nil;
        }
            break;
        case ZHHStringPickerModeCascade:
        {
            // 处理选择器有设置列间距时，选择器的滚动问题
            if (self.columnSpacing > 0) {
                if (component % 2 == 1) {
                    return;
                } else {
                    component = component / 2;
                }
            }
            
            if (component < self.selectedIndexes.count) {
                NSMutableArray *selectedIndexes = [[NSMutableArray alloc]init];
                for (NSInteger i = 0; i < self.selectedIndexes.count; i++) {
                    if (i < component) {
                        [selectedIndexes addObject:self.selectedIndexes[i]];
                    } else if (i == component) {
                        [selectedIndexes addObject:@(row)];
                    } else {
                        [selectedIndexes addObject:@(0)];
                    }
                }
                self.selectedIndexes = [selectedIndexes copy];
            }
            
            // 刷新选择器数据
            [self reloadData];
            
            // 滚动选择时执行 multiChangeBlock
            self.multiChangeBlock ? self.multiChangeBlock([self multiSelectedModels], self.selectedIndexes): nil;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 数据重载与选中值获取

/// 重新加载数据并恢复选中状态
- (void)reloadData {
    // 1.配置数据源
    [self configurePickerData];
    
    // 2.刷新全部组件
    [self.pickerView reloadAllComponents];
    
    // 3.滚动到选择的值
    if (self.pickerMode == ZHHStringPickerModeSingle) {
        
        NSInteger index = MAX(0, MIN(self.selectedIndex, self.dataList.count - 1));
        [self.pickerView selectRow:index inComponent:0 animated:self.selectRowAnimated];
    } else if (self.pickerMode == ZHHStringPickerModeMultiple || self.pickerMode == ZHHStringPickerModeCascade) {

        NSInteger columnCount = self.selectedIndexes.count;
        for (NSInteger i = 0; i < columnCount; i++) {
            NSNumber *rowNumber = self.selectedIndexes[i];
            NSInteger row = MAX(0, rowNumber.integerValue);
            NSInteger component = (self.columnSpacing > 0) ? i * 2 : i;
            [self.pickerView selectRow:row inComponent:component animated:self.selectRowAnimated];
        }
    }
}

/// 获取【单列】选择器当前选中的模型
- (ZHHStringPickerModel *)singleSelectedModel {
    // 容错处理：超出范围返回空模型
    if (self.selectedIndex < 0 || self.selectedIndex >= self.dataList.count) {
        return [[ZHHStringPickerModel alloc] init];
    }
    
    id item = self.dataList[self.selectedIndex];
    
    ZHHStringPickerModel *model = nil;
    if ([item isKindOfClass:[ZHHStringPickerModel class]]) {
        model = (ZHHStringPickerModel *)item;
    } else {
        model = [[ZHHStringPickerModel alloc] init];
        model.text = item;
    }
    
    model.index = self.selectedIndex;
    return model;
}

/// 获取【多列】选择器当前选中的模型数组
- (NSArray<ZHHStringPickerModel *> *)multiSelectedModels {

    // 防御：selectedIndexes 数量若与 dataList 不匹配，取两者最小值
    NSUInteger columnCount = MIN(self.dataList.count, self.selectedIndexes.count);
    NSMutableArray<ZHHStringPickerModel *> *result = [NSMutableArray arrayWithCapacity:columnCount];
    
    for (NSUInteger i = 0; i < columnCount; i++) {
        NSInteger row   = self.selectedIndexes[i].integerValue;      // 当前列选中的行
        NSArray *column = self.dataList[i];                          // 当前列数据
        
        // 容错：若 row 越界，则跳过或补空模型
        if (row < 0 || row >= column.count) {
            [result addObject:[ZHHStringPickerModel modelWithIndex:row text:nil]];
            continue;
        }
        
        id item = column[row];
        ZHHStringPickerModel *model = nil;
        
        if ([item isKindOfClass:ZHHStringPickerModel.class]) {
            model = (ZHHStringPickerModel *)item;
        } else {                                                    // 普通字符串 → 包装成模型
            model = [ZHHStringPickerModel modelWithIndex:row text:[item description]];
        }
        model.index = row;                                           // 同步行号
        [result addObject:model];
    }
    return result.copy;
}

/// 判断指定视图（递归）内部是否有正在滚动的 UIScrollView
/// @param view 需要检测的根视图
/// @return YES 表示存在拖拽或减速中的 UIScrollView
/// @note 使用递归方式遍历视图层级，检测 UIPickerView 内部的滚动状态
/// @warning 递归深度可能较深，但 UIPickerView 层级通常不会太深，性能影响可接受
- (BOOL)isAnyScrollViewRollingInView:(UIView *)view {
    if (!view) {
        return NO;
    }
    
    // 1.若自身就是 UIScrollView，直接判断滚动状态
    if ([view isKindOfClass:UIScrollView.class]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        // 正在拖拽或正在减速滚动，都视为正在滚动
        if (scrollView.isDragging || scrollView.isDecelerating) {
            return YES;
        }
    }
    
    // 2.递归遍历子视图，深度优先搜索
    for (UIView *subview in view.subviews) {
        if ([self isAnyScrollViewRollingInView:subview]) {
            return YES;
        }
    }
    
    return NO;
}

/// 对外暴露：当前 UIPickerView 是否正在滚动
- (BOOL)isRolling {
    return [self isAnyScrollViewRollingInView:self.pickerView];
}

#pragma mark - 视图懒加载

/// 选择器
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = UIColor.clearColor;
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

#pragma mark - Setter 方法

/// 设置数据源（传本地文件名，支持 plist/json 文件）
- (void)setFileName:(NSString *)fileName {
    // 1. 查找资源路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (filePath.length == 0) return;
    
    // 2. 判断文件类型（后缀）
    if ([fileName hasSuffix:@".plist"]) {
        // 2.1 加载 plist 文件为数组
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
        if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            self.dataSource = dataArray;
        }
        
    } else if ([fileName hasSuffix:@".json"]) {
        // 2.2 加载 JSON 文件并解析为数组
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        if (!jsonData) return;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            // ⚠️ 可在此处传入 mapper，如果需要映射字段
            self.dataSource = [self modelsFromJSONArray:(NSArray *)jsonObject mapper:nil];
        } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            // 处理“省-市” 或 “省-市-区” 字典结构
            NSDictionary *dict = (NSDictionary *)jsonObject;
            
            // 判断 value 是 NSDictionary 的为三级结构（省-市-区）

            BOOL isProvinceCityFormat = YES;
            for (id value in dict.allValues) {
                if (![value isKindOfClass:[NSArray class]]) {
                    isProvinceCityFormat = NO;
                    break;
                }
            }

            if (isProvinceCityFormat) {
                self.dataSource = [self modelsFromProvinceCityDictionary:dict];
            } else {
                NSLog(@"⚠️ 不支持的字典结构格式，请确认 JSON 格式是否为省市结构");
            }
        }
    }
}

#pragma mark - 数据模型转换

/// 将字典数组转换为模型数组，支持自定义字段映射，递归解析子节点
- (NSArray<ZHHStringPickerModel *> *)modelsFromJSONArray:(NSArray *)dataArr mapper:(nullable NSDictionary *)mapper {
    if (!mapper) {
        // 默认字段映射
        mapper = @{
            @"code": @"code",
            @"name": @"name",
            @"parentCode": @"parent_code",
            @"extras": @"extras",
            @"children": @"children"
        };
    }
    
    NSMutableArray<ZHHStringPickerModel *> *tempArr = [NSMutableArray arrayWithCapacity:dataArr.count];
    
    for (NSDictionary *dic in dataArr) {
        if (![dic isKindOfClass:[NSDictionary class]]) continue; // 容错：跳过非字典项
        
        ZHHStringPickerModel *model = [[ZHHStringPickerModel alloc] init];
        
        NSString *codeKey = mapper[@"code"];
        if (codeKey) {
            id codeValue = dic[codeKey];
            if (codeValue != nil && codeValue != [NSNull null]) {
                model.code = [NSString stringWithFormat:@"%@", codeValue];
            }
        }
        
        NSString *textKey = mapper[@"name"];
        if (textKey) {
            id textValue = dic[textKey];
            if ([textValue isKindOfClass:[NSString class]]) {
                model.text = textValue;
            } else if (textValue != nil && textValue != [NSNull null]) {
                model.text = [NSString stringWithFormat:@"%@", textValue];
            }
        }
        
        NSString *parentCodeKey = mapper[@"parentCode"];
        if (parentCodeKey) {
            id parentCodeValue = dic[parentCodeKey];
            if (parentCodeValue != nil && parentCodeValue != [NSNull null]) {
                model.parentCode = [NSString stringWithFormat:@"%@", parentCodeValue];
            }
        }
        
        NSString *extrasKey = mapper[@"extras"];
        if (extrasKey) {
            model.extras = dic[extrasKey];
        }
        
        NSString *childrenKey = mapper[@"children"];
        id childrenValue = dic[childrenKey];
        if ([childrenValue isKindOfClass:[NSArray class]]) {
            model.children = [self modelsFromJSONArray:(NSArray *)childrenValue mapper:mapper];
        }
        
        [tempArr addObject:model];
    }
    
    return [tempArr copy];
}

/// 将“省-市”字典数据转换为二级联动模型数组
- (NSArray<ZHHStringPickerModel *> *)modelsFromProvinceCityDictionary:(NSDictionary<NSString *, NSArray<NSString *> *> *)dict {
    NSMutableArray<ZHHStringPickerModel *> *result = [NSMutableArray arrayWithCapacity:dict.count];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *province, NSArray<NSString *> *cities, BOOL *stop) {
        ZHHStringPickerModel *provinceModel = [[ZHHStringPickerModel alloc] init];
        provinceModel.text = province;
        provinceModel.code = province; // 可根据需要生成 code，比如拼音缩写
        
        NSMutableArray<ZHHStringPickerModel *> *cityModels = [NSMutableArray arrayWithCapacity:cities.count];
        for (NSString *city in cities) {
            ZHHStringPickerModel *cityModel = [[ZHHStringPickerModel alloc] init];
            cityModel.text = city;
            cityModel.code = city; // 可自定义编码逻辑
            [cityModels addObject:cityModel];
        }
        
        provinceModel.children = [cityModels copy];
        [result addObject:provinceModel];
    }];
    
    return [result copy];
}

@end
