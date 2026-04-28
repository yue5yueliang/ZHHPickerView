Pod::Spec.new do |s|
  s.name             = 'ZHHPickerView'
  s.version          = '1.0.1'
  s.summary          = 'iOS 日期选择器、字符串选择器（单列/多列/联动）'

  s.description      = <<-DESC
  基于 UIPickerView 的底部弹窗选择器。支持日期选择（多种模式：年月日、时分、年月日时分等）、
  字符串单列/多列/多级联动选择；支持 plist/json 数据源、自定义样式与多语言。
                       DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHPickerView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHPickerView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.0']
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'ZHHPickerView/Classes/**/*.swift'
    core.resources = 'ZHHPickerView/Classes/DatePicker/ZHHPickerView.bundle'
    core.frameworks = 'UIKit', 'Foundation'
  end

  ### 一级目录 Base ###
  s.subspec 'Base' do |base|
    base.source_files = 'ZHHPickerView/Classes/Base/**/*.swift'
    base.frameworks = 'UIKit', 'Foundation'
  end

  ### 一级目录 StringPicker ###
  s.subspec 'StringPicker' do |sp|
    sp.source_files = 'ZHHPickerView/Classes/StringPicker/**/*.swift'
    sp.frameworks = 'UIKit', 'Foundation'
    sp.dependency 'ZHHPickerView/Base'
  end

  ### 一级目录 DatePicker ###
  s.subspec 'DatePicker' do |dp|
    dp.source_files = 'ZHHPickerView/Classes/DatePicker/**/*.swift'
    dp.resources = 'ZHHPickerView/Classes/DatePicker/ZHHPickerView.bundle'
    dp.frameworks = 'UIKit', 'Foundation'
    dp.dependency 'ZHHPickerView/Base'
  end
end
