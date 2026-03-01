//
//  DatePickerViewController.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit
import ZHHPickerView

class DatePickerViewController: UIViewController {

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
    private var sectionModel: ExampleDatePickerSectionModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if sectionIndex >= 0, sectionIndex < viewModel.dateSections.count {
            sectionModel = viewModel.dateSections[sectionIndex]
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

    private func handleDateSystemStyle(itemIndex: Int) {
        let modes: [DatePickerMode] = [.date, .dateAndTime, .time, .countDownTimer]
        guard itemIndex < modes.count else { return }
        let mode = modes[itemIndex]
        let pickerView = DatePickerView(pickerMode: mode)
        pickerView.selectedDate = Date()
        if mode == .date || mode == .dateAndTime {
            var cal = Calendar.current
            if let tz = TimeZone(identifier: "Asia/Shanghai") { cal.timeZone = tz }
            pickerView.minDate = cal.date(byAdding: .year, value: -18, to: Date())
            pickerView.maxDate = cal.date(byAdding: .year, value: 18, to: Date())
        }
        pickerView.resultBlock = { date, value in
            print("日期选择结果：date = \(String(describing: date)), value = \(value ?? "")")
        }
        pickerView.show()
    }

    private func handleDateCustomStyle(itemIndex: Int) {
        guard let items = sectionModel?.items, itemIndex < items.count else { return }
        let item = items[itemIndex]
        let mode = item.mode
        let pickerView = DatePickerView(pickerMode: mode)
        pickerView.selectedDate = Date()
        let hasYMD: Bool = {
            switch mode {
            case .ymdHMS, .ymdHM, .ymdH, .ymd, .ym, .y: return true
            default: return false
            }
        }()
        if hasYMD {
            var cal = Calendar.current
            if let tz = TimeZone(identifier: "Asia/Shanghai") { cal.timeZone = tz }
            pickerView.minDate = cal.date(byAdding: .year, value: -18, to: Date())
            pickerView.maxDate = cal.date(byAdding: .year, value: 18, to: Date())
        }
        if mode == .ymdH {
            pickerView.showAMAndPM = item.showAMAndPM
        } else if mode == .mdHM {
            pickerView.customUnit = ["year": "年", "month": "月", "day": "日", "hour": "時", "minute": "分", "second": "秒"]
        }
        pickerView.resultBlock = { date, value in
            print("日期选择结果：date = \(String(describing: date)), value = \(value ?? "")")
        }
        pickerView.show()
    }
}

extension DatePickerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "DatePickerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        cell.accessoryType = .disclosureIndicator
        if let items = sectionModel?.items, indexPath.row < items.count {
            cell.textLabel?.text = items[indexPath.row].text
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if sectionIndex == 0 {
            handleDateSystemStyle(itemIndex: indexPath.row)
        } else if sectionIndex == 1 {
            handleDateCustomStyle(itemIndex: indexPath.row)
        }
    }
}
