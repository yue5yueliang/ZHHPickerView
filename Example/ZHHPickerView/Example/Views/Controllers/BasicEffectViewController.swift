//
//  BasicEffectViewController.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit
import ZHHPickerView

class BasicEffectViewController: UIViewController {

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
        if !viewModel.stringSections.isEmpty {
            sectionModel = viewModel.stringSections[0]
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

    private func handleBasicEffect(itemIndex: Int) {
        if itemIndex == 0 {
            let pickerView = BasePickerView()
            pickerView.titleLabel.text = "Picker View标题"
            pickerView.titleLabel.backgroundColor = .cyan
            pickerView.cancelButton.backgroundColor = .systemOrange
            pickerView.confirmButton.backgroundColor = .systemOrange
            pickerView.show()
        } else if itemIndex == 1 {
            let pickerView = BasePickerView()
            pickerView.titleLabel.text = "自定义Picker View高度"
            pickerView.titleLabel.backgroundColor = .cyan
            pickerView.pickerViewHeight = 400
            pickerView.pickerHeaderViewHeight = 50
            pickerView.cancelButton.backgroundColor = .systemTeal
            pickerView.cancelButton.layer.cornerRadius = 5
            pickerView.cancelButton.layer.masksToBounds = true
            pickerView.cancelButtonLeftMargin = 20
            pickerView.cancelButtonWidth = 80
            pickerView.cancelButtonHeight = 40
            pickerView.confirmButton.backgroundColor = .systemBrown
            pickerView.confirmButton.layer.cornerRadius = 5
            pickerView.confirmButton.layer.masksToBounds = true
            pickerView.confirmButtonRightMargin = 20
            pickerView.confirmButtonWidth = 80
            pickerView.confirmButtonHeight = 40
            pickerView.show()
        } else if itemIndex == 2 {
            let pickerView = BasePickerView()
            pickerView.titleLabel.backgroundColor = .cyan
            pickerView.titleLabel.text = "不显示取消按钮，隐藏分割线"
            pickerView.titleAlignment = .center
            pickerView.pickerHeaderViewHeight = 50
            pickerView.cancelButtonWidth = 0
            pickerView.confirmButton.backgroundColor = .systemBrown
            pickerView.separatorView.isHidden = true
            pickerView.show()
        } else {
            let pickerView = BasePickerView()
            pickerView.titleLabel.backgroundColor = .cyan
            pickerView.titleLabel.text = "Picker View，标题距离左边30"
            pickerView.titleAlignment = .left
            pickerView.titleLeadingMargin = 30
            pickerView.pickerHeaderViewHeight = 50
            pickerView.cancelButtonWidth = 0
            pickerView.confirmButton.backgroundColor = .systemBrown
            pickerView.confirmButton.layer.cornerRadius = 5
            pickerView.confirmButton.layer.masksToBounds = true
            pickerView.confirmButtonRightMargin = 20
            pickerView.confirmButtonWidth = 80
            pickerView.confirmButtonHeight = 40
            pickerView.show()
        }
    }
}

extension BasicEffectViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "BasicEffectCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        cell.accessoryType = .disclosureIndicator
        if let items = sectionModel?.items, indexPath.row < items.count {
            cell.textLabel?.text = items[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleBasicEffect(itemIndex: indexPath.row)
    }
}
