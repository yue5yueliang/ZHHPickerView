Pod::Spec.new do |s|

  s.name             = 'ZHHPickerView'
  s.version          = '0.0.1'
  s.summary          = '一个功能强大、易于使用的 iOS 选择器组件，支持日期选择器和字符串选择器。'

  s.description      = <<-DESC
  ZHHPickerView 是一个轻量级、高性能的 iOS 选择器组件库，基于 UIKit 实现。

  

  主要特性：

  - 📅 日期选择器：支持系统样式和自定义样式，涵盖年月日、时分秒等多种格式

  - 📝 字符串选择器：支持单列、多列、多级联动选择，灵活配置数据源

  - 🎨 丰富的自定义选项：支持自定义样式、颜色、字体、单位显示等

  - 🌍 国际化支持：内置多语言支持（中文、英文、繁体中文）

  - ⚡ 性能优化：优化的数据加载和渲染机制，流畅的滚动体验

  - 🔄 完整的回调机制：支持选择结果回调、滚动回调等

  - 📱 灵活配置：支持最小/最大日期限制、默认选中值、自动选择等

  - 🎯 易于集成：简洁的 API 设计，支持代码和文件两种数据源方式

  

  适用于日期选择、时间选择、地区选择、选项选择等多种场景。

  最低支持 iOS 13.0。

  DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHPickerView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 
    '桃色三岁' => '136769890@qq.com'
  }
  s.source           = { 
    :git => 'https://github.com/yue5yueliang/ZHHPickerView.git', 
    :tag => s.version.to_s 
  }

  s.social_media_url = 'https://github.com/yue5yueliang'
  s.requires_arc     = true
  s.ios.deployment_target = '13.0'
  s.swift_version    = nil  # 纯 Objective-C 项目
  s.default_subspec = 'Core'

  # 基础模块（所有选择器的基础类）
  s.subspec 'Base' do |base|
    base.source_files = 'ZHHPickerView/Classes/Base/**/*.{h,m}'
    base.public_header_files = 'ZHHPickerView/Classes/Base/**/*.h'
    base.frameworks = 'UIKit', 'Foundation'
  end

  # 日期选择器模块
  s.subspec 'DatePicker' do |datePicker|
    datePicker.dependency 'ZHHPickerView/Base'
    datePicker.source_files = 'ZHHPickerView/Classes/DatePicker/**/*.{h,m}'
    datePicker.public_header_files = 'ZHHPickerView/Classes/DatePicker/**/*.h'
    datePicker.resource_bundles = {
      'ZHHPickerView' => ['ZHHPickerView/Classes/DatePicker/ZHHPickerView.bundle/**/*']
    }
    datePicker.frameworks = 'UIKit', 'Foundation'
  end

  # 字符串选择器模块
  s.subspec 'StringPicker' do |stringPicker|
    stringPicker.dependency 'ZHHPickerView/Base'
    stringPicker.source_files = 'ZHHPickerView/Classes/StringPicker/**/*.{h,m}'
    stringPicker.public_header_files = 'ZHHPickerView/Classes/StringPicker/**/*.h'
    stringPicker.frameworks = 'UIKit', 'Foundation'
  end

  # 完整模块（包含所有功能，默认）
  s.subspec 'Core' do |core|
    core.dependency 'ZHHPickerView/Base'
    core.dependency 'ZHHPickerView/DatePicker'
    core.dependency 'ZHHPickerView/StringPicker'
    core.frameworks = 'UIKit', 'Foundation'
  end

end
