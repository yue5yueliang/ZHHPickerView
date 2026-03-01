//
//  StringPickerView.swift
//  ZHHPickerView
//

import UIKit

/// 字符串选择器模式
public enum StringPickerMode: Int {
    /// 单列选择（如性别、颜色）
    case single
    /// 多列选择，彼此独立（如身高、体重）
    case multiple
    /// 多级联动选择（如省市区）
    case cascade
}

/// 字符串选择器
open class StringPickerView: BasePickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    /// 字符串选择器的显示模式（单列、多列、多级联动）
    public var pickerMode: StringPickerMode = .single
    /// 数据源：单列传一维数组，多列传二维数组，联动传树状模型数组
    public var dataSource: [Any]?
    /// 数据源文件名（支持 plist/json），设置后自动加载
    public var fileName: String? {
        didSet { loadFromFileName() }
    }
    /// 默认选中的索引（单列模式下使用）
    public var selectedIndex: Int = 0
    /// 每列默认选中的索引（多列模式下使用）
    public var selectedIndexes: [Int] = []
    /// 显示列数（联动模式可强制展示固定列数）
    public var showColumnNum: Int = 0
    /// picker 行高，默认 40
    public var pickerRowHeight: CGFloat = 40
    /// picker 列宽
    public var columnWidth: CGFloat = 0
    /// picker 列间隔
    public var columnSpacing: CGFloat = 0
    /// picker 文本颜色，默认 labelColor
    public var pickerTextColor: UIColor? = .label
    /// picker 文本字体，默认 18pt
    public var pickerTextFont: UIFont? = .systemFont(ofSize: 18)
    /// picker 文本最大行数，默认 2
    public var maxTextLines: Int = 2
    /// 滚动至选择行动画，默认 NO
    public var selectRowAnimated: Bool = false

    /// 滚动过程中触发的选择回调（单列）
    public var singleChangeBlock: ((StringPickerModel?, Int) -> Void)?
    /// 滚动过程中触发的选择回调（多列）
    public var multiChangeBlock: (([StringPickerModel]?, [Int]?) -> Void)?
    /// 点击"确定"后触发的选择回调（单列）
    public var singleResultBlock: ((StringPickerModel?, Int) -> Void)?
    /// 点击"确定"后触发的选择回调（多列）
    public var multiResultBlock: (([StringPickerModel]?, [Int]?) -> Void)?

    /// 当前显示的数据源（支持单列/多列/联动）
    var dataList: [[Any]] = []
    /// UIPickerView 实例
    var pickerView = UIPickerView()
    /// 当前正在滚动的列（component）
    var rollingComponent: Int = 0
    /// 当前正在滚动的行（row）
    var rollingRow: Int = 0

    /// 初始化文本选择器
    public init(pickerMode: StringPickerMode) {
        super.init()
        self.pickerMode = pickerMode
        pickerTextFont = .systemFont(ofSize: 18)
        pickerTextColor = .label
        maxTextLines = 2
        pickerRowHeight = 40
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func show() {
        // 将 picker 加入内容区并约束到底部安全区上方
        contentView.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: pickerHeaderView.bottomAnchor),
            pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),
            pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .clear
        reloadData()
        super.show()
    }

    public override func handleConfirmAction() {
        // 若仍在滚动，先同步当前滚动到的行到选中状态再回调
        if isRolling {
            pickerView(pickerView, didSelectRow: rollingRow, inComponent: rollingComponent)
        }
        switch pickerMode {
        case .single:
            singleResultBlock?(singleSelectedModel(), selectedIndex)
        case .multiple, .cascade:
            multiResultBlock?(multiSelectedModels(), selectedIndexes)
        }
        super.handleConfirmAction()
    }
}

// MARK: - 数据
extension StringPickerView {

    /// 从 fileName 加载数据源（支持 plist/json）
    func loadFromFileName() {
        guard let name = fileName else { return }
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
        if name.hasSuffix(".plist") {
            if let arr = NSArray(contentsOfFile: path) as? [Any], !arr.isEmpty {
                dataSource = arr
            }
        } else if name.hasSuffix(".json") {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let json = try? JSONSerialization.jsonObject(with: data) else { return }
            // 支持 [{}] 树状结构或 {"省": ["市", ...]} 键值对
            if let arr = json as? [Any] {
                dataSource = modelsFromJSONArray(arr)
            } else if let dict = json as? [String: [String]] {
                dataSource = modelsFromProvinceCityDict(dict)
            }
        }
    }

    /// 配置选择器数据和默认选中状态
    func configurePickerData() {
        guard isDataSourceValid else { return }
        switch pickerMode {
        case .single:
            setupSingleData()
        case .multiple:
            setupMultipleData()
        case .cascade:
            setupLinkageData()
        }
    }

    /// 数据源格式校验
    var isDataSourceValid: Bool {
        guard let src = dataSource, !src.isEmpty else { return false }
        let first = src.first!
        switch pickerMode {
        case .single:
            return first is String || first is StringPickerModel
        case .multiple:
            return first is [Any]
        case .cascade:
            return first is StringPickerModel
        }
    }

    /// 单列模式初始化
    func setupSingleData() {
        dataList = [dataSource!]
        if selectedIndex < 0 || selectedIndex >= dataList[0].count {
            selectedIndex = 0
        }
    }

    /// 多列模式初始化
    func setupMultipleData() {
        dataList = dataSource as! [[Any]]
        selectedIndexes = (0..<dataList.count).map { i in
            let idx = i < selectedIndexes.count ? selectedIndexes[i] : 0
            let arr = dataList[i]
            return min(max(idx, 0), max(0, arr.count - 1))
        }
    }

    /// 联动模式初始化（根据树状结构构建每级数据列表）
    func setupLinkageData() {
        var list: [[Any]] = []
        var indexes: [Int] = []
        var current = dataSource as! [StringPickerModel]
        var depth = 0

        while !current.isEmpty {
            list.append(current)
            let idx = depth < selectedIndexes.count ? min(max(selectedIndexes[depth], 0), current.count - 1) : 0
            indexes.append(idx)
            current = (current[idx].children ?? [])
            depth += 1
        }

        if showColumnNum > 0 {
            if showColumnNum < list.count {
                list = Array(list.prefix(showColumnNum))
                indexes = Array(indexes.prefix(showColumnNum))
            } else {
                for _ in list.count..<showColumnNum {
                    let placeholder = StringPickerModel()
                    list.append([placeholder])
                    indexes.append(0)
                }
            }
        }
        dataList = list
        selectedIndexes = indexes
    }

    /// JSON 数组转树状模型（支持 text/name、children）
    func modelsFromJSONArray(_ arr: [Any]) -> [StringPickerModel] {
        arr.compactMap { item -> StringPickerModel? in
            guard let d = item as? [String: Any] else { return nil }
            let m = StringPickerModel(dictionary: d)
            m.text = (d["text"] as? String) ?? (d["name"] as? String)
            if let children = d["children"] as? [[String: Any]] {
                m.children = children.map { child in
                    let c = StringPickerModel(dictionary: child)
                    c.text = (child["text"] as? String) ?? (child["name"] as? String)
                    return c
                }
            }
            return m
        }
    }

    /// 省-城市字典转树状模型，用于联动
    func modelsFromProvinceCityDict(_ dict: [String: [String]]) -> [StringPickerModel] {
        dict.map { province, cities in
            let p = StringPickerModel()
            p.text = province
            p.code = province
            p.children = cities.map { city in
                let c = StringPickerModel()
                c.text = city
                c.code = city
                return c
            }
            return p
        }
    }
}

// MARK: - UIPickerView 数据源
extension StringPickerView {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerMode {
        case .single:
            return 1
        case .multiple, .cascade:
            // 列间隔时在每两列之间插一列占位，总列数 = 数据列数*2-1
            return columnSpacing > 0 ? dataList.count * 2 - 1 : dataList.count
        }
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerMode {
        case .single:
            return dataList.first?.count ?? 0
        case .multiple, .cascade:
            // 奇数 component 为间隔列，只占 1 行
            if columnSpacing > 0 && component % 2 == 1 { return 1 }
            let c = columnSpacing > 0 ? component / 2 : component
            guard c < dataList.count else { return 0 }
            return dataList[c].count
        }
    }
}

// MARK: - UIPickerView 代理
extension StringPickerView {

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        pickerRowHeight
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        // 间隔列宽度取 columnSpacing
        if columnSpacing > 0 && component % 2 == 1 { return columnSpacing }
        let total = CGFloat(numberOfComponents(in: pickerView))
        let w = pickerView.bounds.width / total - 5
        if columnWidth > 0 && columnWidth <= w { return columnWidth }
        return w
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? {
            let l = UILabel()
            l.backgroundColor = .clear
            l.textAlignment = .center
            l.font = pickerTextFont
            l.textColor = pickerTextColor ?? .label
            l.numberOfLines = maxTextLines
            l.adjustsFontSizeToFitWidth = true
            l.minimumScaleFactor = 0.5
            return l
        }()

        // 记录当前 component/row，确认时若在滚动可同步到选中状态
        rollingComponent = component
        rollingRow = pickerView.selectedRow(inComponent: component)
        if rollingRow < 0 { rollingRow = 0 }

        if columnSpacing > 0 && component % 2 == 1 {
            label.text = ""
            return label
        }

        let c = columnSpacing > 0 ? component / 2 : component
        guard c < dataList.count, row < dataList[c].count else {
            label.text = ""
            return label
        }
        let item = dataList[c][row]
        label.text = (item as? StringPickerModel)?.text ?? String(describing: item)
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerMode {
        case .single:
            selectedIndex = row
            singleChangeBlock?(singleSelectedModel(), selectedIndex)
        case .multiple:
            var c = component
            if columnSpacing > 0 {
                if c % 2 == 1 { return }
                c = c / 2
            }
            if c < selectedIndexes.count {
                var arr = selectedIndexes
                arr[c] = row
                selectedIndexes = arr
            }
            multiChangeBlock?(multiSelectedModels(), selectedIndexes)
        case .cascade:
            var c = component
            if columnSpacing > 0 {
                if c % 2 == 1 { return }
                c = c / 2
            }
            if c < selectedIndexes.count {
                // 当前列及之后的列重置：当前列用 row，后续列用 0
                var arr: [Int] = []
                for i in 0..<selectedIndexes.count {
                    arr.append(i < c ? selectedIndexes[i] : (i == c ? row : 0))
                }
                selectedIndexes = arr
            }
            reloadData() // 联动需刷新下级列数据
            multiChangeBlock?(multiSelectedModels(), selectedIndexes)
        }
    }
}

// MARK: - 刷新与选中
extension StringPickerView {

    /// 重新配置数据、刷新列表并恢复选中行
    func reloadData() {
        configurePickerData()
        pickerView.reloadAllComponents()
        if pickerMode == .single {
            let idx = min(max(selectedIndex, 0), max(0, (dataList.first?.count ?? 1) - 1))
            pickerView.selectRow(idx, inComponent: 0, animated: selectRowAnimated)
        } else {
            for i in 0..<selectedIndexes.count {
                let row = min(max(selectedIndexes[i], 0), max(0, (dataList[safe: i]?.count ?? 1) - 1))
                let comp = columnSpacing > 0 ? i * 2 : i
                pickerView.selectRow(row, inComponent: comp, animated: selectRowAnimated)
            }
        }
    }

    /// 获取【单列】选择器当前选中的模型
    func singleSelectedModel() -> StringPickerModel? {
        guard selectedIndex >= 0, selectedIndex < (dataList.first?.count ?? 0) else {
            return StringPickerModel.model(index: selectedIndex, text: nil)
        }
        let item = dataList[0][selectedIndex]
        if let m = item as? StringPickerModel {
            m.index = selectedIndex
            return m
        }
        return StringPickerModel.model(index: selectedIndex, text: String(describing: item))
    }

    /// 获取【多列】选择器当前选中的模型数组
    func multiSelectedModels() -> [StringPickerModel] {
        let count = min(dataList.count, selectedIndexes.count)
        return (0..<count).map { i in
            let row = selectedIndexes[i]
            let col = dataList[i]
            guard row >= 0, row < col.count else {
                return StringPickerModel.model(index: row, text: nil)
            }
            let item = col[row]
            if let m = item as? StringPickerModel {
                m.index = row
                return m
            }
            return StringPickerModel.model(index: row, text: String(describing: item))
        }
    }

    /// 当前选择器是否正在滚动
    public var isRolling: Bool {
        isAnyScrollViewRolling(in: pickerView)
    }

    /// 递归判断 view 及其子视图中的 UIScrollView 是否在拖拽或减速
    func isAnyScrollViewRolling(in view: UIView?) -> Bool {
        guard let v = view else { return false }
        if let sv = v as? UIScrollView, sv.isDragging || sv.isDecelerating { return true }
        for sub in v.subviews {
            if isAnyScrollViewRolling(in: sub) { return true }
        }
        return false
    }
}

// 安全下标，越界返回 nil
private extension Array {
    subscript(safe i: Int) -> Element? {
        indices.contains(i) ? self[i] : nil
    }
}
