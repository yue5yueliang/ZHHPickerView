//
//  ZHHStringPickerView.h
//  ZHHPickerView_Example
//
//  Created by 桃色三岁 on 2025/6/11.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHBasePickerView.h"
#import "ZHHStringPickerModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 字符串选择器显示模式
typedef NS_ENUM(NSInteger, ZHHStringPickerMode) {
    /// 单列选择（如性别、颜色）
    ZHHStringPickerModeSingle,

    /// 多列选择，彼此独立（如身高、体重）
    ZHHStringPickerModeMultiple,

    /// 多级联动选择（如省市区）
    ZHHStringPickerModeCascade
};

/// 单列选择结果回调
/// @param selectedModel 选中的数据模型
/// @param selectedIndex 选中的索引
typedef void(^ZHHSingleResultBlock)(ZHHStringPickerModel * _Nullable model, NSInteger index);

/// 多列选择结果回调
/// @param selectedModels 每列选中的数据模型数组（顺序对应列索引）
/// @param selectedIndexes 每列选中的索引数组（顺序对应列索引）
typedef void(^ZHHMultiResultBlock)(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes);

/// 字符串选择器统一回调（支持单列/多列）
/// @param selectedModels 每列选中的数据模型数组
/// @param selectedIndexes 每列选中的索引数组
typedef void(^ZHHStringPickerResultBlock)(NSArray<ZHHStringPickerModel *> * _Nullable models, NSArray<NSNumber *> * _Nullable indexes);

@interface ZHHStringPickerView : ZHHBasePickerView
/**
 *  1.设置数据源
 *    单列：@[@"男", @"女", @"其他"]，或直接传一维模型数组(NSArray <ZHHStringPickerModel *>*)
 *    多列：@[@[@"语文", @"数学", @"英语"], @[@"优秀", @"良好"]]，或直接传多维模型数组
 *
 *    联动：传树状结构模型数组(NSArray <ZHHStringPickerModel *>*)，对应的 JSON 基本数据格式如下：
 
     [
       {
         "name" : "北京市",
         "children" : [
             { "name": "北京城区", "children": [{ "name": "东城区" }, { "name": "西城区" }] }
         ]
       },
       {
         "name" : "浙江省",
         "children" : [
             { "name": "杭州市", "children": [{ "name": "西湖区" }, { "name": "滨江区" }] },
             { "name": "宁波市", "children": [{ "name": "海曙区" }, { "name": "江北区" }] }
         ]
       }
     ]

    提示：可以把上面的 JSON 数据放到xxx.json文件中，使用fileName进行使用
    pickerView.fileName = @"xxx.json";
 */
@property (nullable, nonatomic, copy) NSArray *dataSource;

/**
 *  2.设置数据源（传本地文件名，支持 plist/json 文件）
 *    ① 对于单列/多列选择器：可以直接传 plist 文件名（如：@"education_data.plist"，要带后缀名）
 *    ② 对于多列联动选择器：可以直接传 JSON 文件名（如：@"region_tree_data.json"，要带后缀名），另外要注意JSON数据源的格式（参考上面设置数据源）
 *
 *    场景：可以将数据源数据（数组/JSON格式数据）放到 plist/json 文件中，直接传文件名更加简单
 */
@property (nullable, nonatomic, copy) NSString *fileName;

#pragma mark - 配置项

/// 字符串选择器的显示模式（单列、多列、多级联动）
@property (nonatomic, assign) ZHHStringPickerMode pickerMode;

/// 设置默认选中的索引（单列模式下使用）
/// @discussion 从 0 开始计数，超出范围会自动处理为合法值
@property (nonatomic, assign) NSInteger selectedIndex;

/// 设置每列默认选中的索引（多列模式下使用）
/// @discussion 每个元素表示对应列的选中索引，从 0 开始计数
@property (nullable, nonatomic, copy) NSArray<NSNumber *> *selectedIndexes;

/// 显示的列数（层级数），默认根据数据源自动判断；可用于强制展示固定列数
@property (nonatomic, assign) NSUInteger numberOfVisibleColumns;

/// 设置选择器显示的列数(即层级数)，默认是根据数据源层级动态计算显示
@property (nonatomic, assign) NSUInteger showColumnNum;

#pragma mark - 样式配置

/// 设置 picker 的行高，默认为 40
@property (nonatomic, assign) CGFloat pickerRowHeight;

/// 设置 picker 的列宽
@property (nonatomic, assign) CGFloat columnWidth;

/// 设置 picker 的列间隔
@property (nonatomic, assign) CGFloat columnSpacing;

/// 设置 picker 文本的颜色，默认为 [UIColor labelColor]
@property (nullable, nonatomic, strong) UIColor *pickerTextColor;

/// 设置 picker 文本的字体，默认为 [UIFont systemFontOfSize:18.0f]
@property (nullable, nonatomic, strong) UIFont *pickerTextFont;

/// 设置 picker 文本支持的最大行数，默认为 2
@property (nonatomic, assign) NSUInteger maxTextLines;

#pragma mark - 回调事件

/// 滚动过程中触发的选择回调（单列）
@property (nullable, nonatomic, copy) ZHHSingleResultBlock singleChangeBlock;

/// 滚动过程中触发的选择回调（多列）
@property (nullable, nonatomic, copy) ZHHMultiResultBlock multiChangeBlock;

/// 点击“确定”按钮后触发的选择回调（单列）
@property (nullable, nonatomic, copy) ZHHSingleResultBlock singleResultBlock;

/// 点击“确定”按钮后触发的选择回调（多列）
@property (nullable, nonatomic, copy) ZHHMultiResultBlock multiResultBlock;

#pragma mark - 状态与控制

/// 当前选择器是否正在滚动（可用于避免滚动未停止时点击“确定”按钮导致数据异常）
@property (nonatomic, readonly, assign, getter=isRolling) BOOL rolling;

/// 滚动至选择行动画，默认为 NO
@property (nonatomic, assign) BOOL selectRowAnimated;

#pragma mark - 初始化方法

/// 初始化文本选择器
/// @param pickerMode 文本选择器显示类型
- (instancetype)initWithPickerMode:(ZHHStringPickerMode)pickerMode;
@end

NS_ASSUME_NONNULL_END
