//
//  StringPickerModel.swift
//  ZHHPickerView
//

import Foundation

/// 字符串选择器数据模型
open class StringPickerModel: NSObject {
    /// 唯一编码，标识项的实际值（如省份编码等）
    public var code: String?
    /// 显示文本（用于 picker 展示）
    public var text: String?
    /// 子级数据（多级联动使用）
    public var children: [StringPickerModel]?
    /// 父级编码（可选字段，用于链式定位）
    public var parentCode: String?
    /// 扩展字段（用于业务扩展）
    public var extras: Any?
    /// 当前项在 picker 中的选中位置（由外部赋值）
    public var index: Int = 0

    public override init() {
        super.init()
    }

    /// 根据字典初始化模型对象（支持递归解析子节点）
    /// - Parameter dictionary: 包含 code、text、parent_code、extras、children 等
    public init(dictionary: [String: Any]) {
        super.init()
        code = dictionary["code"] as? String
        text = (dictionary["text"] as? String) ?? (dictionary["name"] as? String)
        parentCode = dictionary["parent_code"] as? String
        extras = dictionary["extras"]
        if let arr = dictionary["children"] as? [[String: Any]] {
            children = arr.map { StringPickerModel(dictionary: $0) }
        }
    }

    /// 快捷创建仅包含 index 和 text 的模型对象
    public static func model(index: Int, text: String?) -> StringPickerModel {
        let m = StringPickerModel()
        m.index = index
        m.text = text
        return m
    }
}
