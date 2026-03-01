//
//  Bundle+Picker.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import Foundation

extension Bundle {

    /// 获取 ZHHPickerView.bundle 资源包
    static var zhhPickerBundle: Bundle? {
        struct Static {
            static var bundle: Bundle?
            static var once: Bool = false
        }
        if !Static.once {
            Static.once = true
            for b in [Bundle(for: BasePickerView.self), .main] {
                if let path = b.path(forResource: "ZHHPickerView", ofType: "bundle") {
                    Static.bundle = Bundle(path: path)
                    break
                }
            }
        }
        return Static.bundle
    }

    /// 获取国际化后的文本
    /// - Parameters:
    ///   - key: Localizable.strings 中的 key
    ///   - language: 语言（如 zh-Hans、en），nil 时跟随系统
    static func zhhLocalizedString(key: String, language: String?) -> String {
        zhhLocalizedString(key: key, value: nil, language: language)
    }

    /// 获取国际化后的文本（内部实现）
    /// - Parameters:
    ///   - key: 本地化字符串的 key
    ///   - value: 默认值（未找到时使用）
    ///   - language: 语言标识符，nil 时使用系统首选语言
    static func zhhLocalizedString(key: String, value: String?, language: String?) -> String {
        var lang = language ?? Locale.preferredLanguages.first ?? "en"
        if lang.hasPrefix("en") {
            lang = "en"
        } else if lang.hasPrefix("zh") {
            lang = lang.contains("Hans") ? "zh-Hans" : "zh-Hant"
        } else {
            lang = "en"
        }

        var result = value
        if let pickerBundle = zhhPickerBundle,
           let lprojPath = pickerBundle.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: lprojPath) {
            result = bundle.localizedString(forKey: key, value: value, table: nil)
        }
        return Bundle.main.localizedString(forKey: key, value: result, table: nil)
    }
}
