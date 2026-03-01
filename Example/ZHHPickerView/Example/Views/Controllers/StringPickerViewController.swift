//
//  StringPickerViewController.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//
import UIKit
import ZHHPickerView

class StringPickerViewController: UIViewController {

    var sectionIndex: Int = 0

    private lazy var mainTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGray6
        tv.separatorInset = .zero
        tv.delegate = self
        tv.dataSource = self
        if #available(iOS 15.0, *) { tv.sectionHeaderTopPadding = 0 }
        return tv
    }()

    private let viewModel = ExamplePickerViewModel()
    private var sectionModel: ExamplePickerModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if sectionIndex >= 0, sectionIndex < viewModel.stringSections.count {
            sectionModel = viewModel.stringSections[sectionIndex]
        }
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func handlePicker(sectionIndex: Int, itemIndex: Int) {
        switch sectionIndex {
        case 1: handleFixedColumnPicker(itemIndex: itemIndex)
        case 2: handleCascadePicker(itemIndex: itemIndex)
        case 3: handleSingleLevelRegion(itemIndex: itemIndex)
        case 4: handleMultiLevelRegion(itemIndex: itemIndex)
        default: break
        }
    }

    private func handleFixedColumnPicker(itemIndex: Int) {
        if itemIndex == 0 {
            let pickerView = StringPickerView(pickerMode: .single)
            pickerView.dataSource = ["白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "摩羯座", "水瓶座", "双鱼座"]
            pickerView.titleLabel.text = "选择星座"
            pickerView.pickerTextColor = .systemBlue
            pickerView.pickerTextFont = .systemFont(ofSize: 18)
            pickerView.pickerRowHeight = 44
            pickerView.selectedIndex = 7
            pickerView.singleResultBlock = { model, index in
                if let m = model {
                    print("选择结果：index = \(m.index)，text = \(m.text ?? "")")
                } else {
                    print("获取到模型，仅索引 index = \(index)")
                }
            }
            pickerView.show()
        } else if itemIndex == 1 {
            let pickerView = StringPickerView(pickerMode: .multiple)
            pickerView.dataSource = [
                ["150‑155", "156‑160", "161‑165", "166‑170", "171‑175", "176‑180", "181‑185", "186‑190"],
                ["40‑49 kg", "50‑59 kg", "60‑69 kg", "70‑79 kg", "80‑89 kg", "90‑99 kg"]
            ]
            pickerView.pickerTextColor = .systemBlue
            pickerView.pickerTextFont = .systemFont(ofSize: 18)
            pickerView.pickerRowHeight = 44
            pickerView.columnSpacing = 16
            pickerView.selectRowAnimated = true
            pickerView.multiResultBlock = { models, indexes in
                var desc = ""
                if let m = models, let idx = indexes {
                    for (i, obj) in m.enumerated() where i < idx.count {
                        desc += "\(obj.text ?? "")(\(idx[i]))  "
                    }
                }
                print("多列选择结果：\(desc)")
            }
            pickerView.show()
        } else {
            let pickerView = StringPickerView(pickerMode: .multiple)
            pickerView.dataSource = [
                ["150‑155", "156‑160", "161‑165", "166‑170", "171‑175", "176‑180", "181‑185", "186‑190"],
                ["40‑49 kg", "50‑59 kg", "60‑69 kg", "70‑79 kg", "80‑89 kg", "90‑99 kg"],
                ["A", "B", "AB", "O", "其他"]
            ]
            pickerView.pickerTextColor = .systemBlue
            pickerView.pickerTextFont = .systemFont(ofSize: 18)
            pickerView.pickerRowHeight = 44
            pickerView.columnSpacing = 16
            pickerView.selectRowAnimated = true
            pickerView.multiResultBlock = { models, indexes in
                var desc = ""
                if let m = models, let idx = indexes {
                    for (i, obj) in m.enumerated() where i < idx.count {
                        desc += "\(obj.text ?? "")(\(idx[i]))  "
                    }
                }
                print("多列选择结果：\(desc)")
            }
            pickerView.show()
        }
    }

    private func handleCascadePicker(itemIndex: Int) {
        if itemIndex == 0 {
            let apple = StringPickerModel()
            apple.text = "苹果"
            apple.children = [
                .model(index: 0, text: "红富士"),
                .model(index: 1, text: "青苹果"),
                .model(index: 2, text: "国光")
            ]
            let banana = StringPickerModel()
            banana.text = "香蕉"
            banana.children = [
                .model(index: 0, text: "海南香蕉"),
                .model(index: 1, text: "菲律宾香蕉")
            ]
            let grape = StringPickerModel()
            grape.text = "葡萄"
            grape.children = [
                .model(index: 0, text: "阳光玫瑰"),
                .model(index: 1, text: "夏黑"),
                .model(index: 2, text: "巨峰")
            ]
            let pickerView = StringPickerView(pickerMode: .cascade)
            pickerView.dataSource = [apple, banana, grape]
            pickerView.pickerTextColor = .darkGray
            pickerView.pickerTextFont = .systemFont(ofSize: 17)
            pickerView.pickerRowHeight = 40
            pickerView.selectRowAnimated = true
            pickerView.columnSpacing = 12
            pickerView.selectedIndexes = [0, 0]
            pickerView.multiResultBlock = { models, _ in
                if let m = models, m.count == 2 {
                    print("联动选择结果：水果 = \(m[0].text ?? "")，品种 = \(m[1].text ?? "")")
                }
            }
            pickerView.show()
        } else {
            let beijing = StringPickerModel()
            beijing.text = "北京市"
            let bjCity = StringPickerModel()
            bjCity.text = "北京市"
            bjCity.children = [
                .model(index: 0, text: "朝阳区"),
                .model(index: 1, text: "海淀区"),
                .model(index: 2, text: "东城区")
            ]
            beijing.children = [bjCity]
            let guangdong = StringPickerModel()
            guangdong.text = "广东省"
            let gz = StringPickerModel()
            gz.text = "广州市"
            gz.children = [
                .model(index: 0, text: "天河区"),
                .model(index: 1, text: "越秀区")
            ]
            let sz = StringPickerModel()
            sz.text = "深圳市"
            sz.children = [
                .model(index: 0, text: "南山区"),
                .model(index: 1, text: "福田区")
            ]
            guangdong.children = [gz, sz]
            let zhejiang = StringPickerModel()
            zhejiang.text = "浙江省"
            let hz = StringPickerModel()
            hz.text = "杭州市"
            hz.children = [
                .model(index: 0, text: "西湖区"),
                .model(index: 1, text: "滨江区")
            ]
            zhejiang.children = [hz]
            let pickerView = StringPickerView(pickerMode: .cascade)
            pickerView.dataSource = [beijing, guangdong, zhejiang]
            pickerView.pickerTextFont = .systemFont(ofSize: 18)
            pickerView.pickerTextColor = .black
            pickerView.pickerRowHeight = 44
            pickerView.columnSpacing = 10
            pickerView.selectedIndexes = [1, 0, 1]
            pickerView.multiResultBlock = { models, _ in
                if let m = models, m.count == 3 {
                    print("选择结果：\(m[0].text ?? "") / \(m[1].text ?? "") / \(m[2].text ?? "")")
                }
            }
            pickerView.show()
        }
    }

    private func handleSingleLevelRegion(itemIndex: Int) {
        let files = ["provinces.json", "cities.json", "areas.json", "streets.json", "villages.json"]
        guard itemIndex < files.count else { return }
        let pickerView = StringPickerView(pickerMode: .cascade)
        pickerView.pickerTextColor = .systemBlue
        pickerView.pickerTextFont = .systemFont(ofSize: 18)
        pickerView.pickerRowHeight = 44
        pickerView.columnSpacing = 16
        pickerView.selectRowAnimated = true
        pickerView.fileName = files[itemIndex]
        pickerView.multiResultBlock = { models, indexes in
            var desc = ""
            if let m = models, let idx = indexes {
                for (i, obj) in m.enumerated() where i < idx.count {
                    desc += "\(obj.text ?? "") \(obj.code ?? "") (\(idx[i]))  "
                }
            }
            print("多列选择结果：\(desc)")
        }
        pickerView.show()
    }

    private func handleMultiLevelRegion(itemIndex: Int) {
        let files = ["pc-code.json", "pca-code.json", "pcas-code.json"]
        guard itemIndex < files.count else { return }
        let pickerView = StringPickerView(pickerMode: .cascade)
        pickerView.pickerTextColor = .systemBlue
        pickerView.pickerTextFont = .systemFont(ofSize: 18)
        pickerView.pickerRowHeight = 44
        pickerView.columnSpacing = itemIndex == 1 ? 0 : 16
        pickerView.selectRowAnimated = true
        pickerView.fileName = files[itemIndex]
        pickerView.multiResultBlock = { models, indexes in
            var desc = ""
            if let m = models, let idx = indexes {
                for (i, obj) in m.enumerated() where i < idx.count {
                    desc += "\(obj.text ?? "") \(obj.code ?? "") (\(idx[i]))  "
                }
            }
            print("多列选择结果：\(desc)")
        }
        pickerView.show()
    }
}

extension StringPickerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "StringPickerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        cell.accessoryType = .disclosureIndicator
        if let items = sectionModel?.items, indexPath.row < items.count {
            cell.textLabel?.text = items[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handlePicker(sectionIndex: sectionIndex, itemIndex: indexPath.row)
    }
}
