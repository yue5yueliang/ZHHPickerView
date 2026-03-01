//
//  ExampleViewController.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit
import ZHHPickerView

/// 选择器示例首页
class ExampleViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择器示例"
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ExampleViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.homeSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < viewModel.homeSections.count else { return 0 }
        return viewModel.homeSections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "HomeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        cell.accessoryType = .disclosureIndicator
        if indexPath.section < viewModel.homeSections.count,
           indexPath.row < viewModel.homeSections[indexPath.section].items.count {
            cell.textLabel?.text = viewModel.homeSections[indexPath.section].items[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < viewModel.homeSections.count else { return nil }
        return viewModel.homeSections[section].title
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section < viewModel.homeSections.count,
              indexPath.row < viewModel.homeSections[indexPath.section].items.count else { return }
        let itemTitle = viewModel.homeSections[indexPath.section].items[indexPath.row]

        if indexPath.section == 0 {
            let vc = BasicEffectViewController()
            vc.title = itemTitle
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            let vc = StringPickerViewController()
            vc.sectionIndex = indexPath.row + 1
            vc.title = itemTitle
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 2 {
            let vc = DatePickerViewController()
            vc.sectionIndex = indexPath.row
            vc.title = itemTitle
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
