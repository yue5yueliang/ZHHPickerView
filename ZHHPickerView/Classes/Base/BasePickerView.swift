//
//  BasePickerView.swift
//  ZHHPickerView
//
//  Created by 桃色三岁 on 2025/6/10.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 基础选择器弹窗
open class BasePickerView: UIView {

    // MARK: - 公共子视图

    /// 背景遮罩视图（用于点击关闭或背景虚化）
    public let backgroundDimView = UIView()
    /// 内容容器视图（包含 header 和 picker 区域）
    public let contentView = UIView()
    /// 顶部控制区域视图（包含标题、取消和确定按钮）
    public let pickerHeaderView = UIView()
    /// 顶部左侧取消按钮
    public let cancelButton = UIButton(type: .system)
    /// 顶部右侧确定按钮
    public let confirmButton = UIButton(type: .system)
    /// 顶部中间标题标签
    public let titleLabel = UILabel()
    /// 顶部与 pickerView 之间的分割线视图
    public let separatorView = UIView()

    // MARK: - 样式配置

    /// 标题对齐方式（默认居中）
    public var titleAlignment: NSTextAlignment = .center {
        didSet { updateTitleAlignment() }
    }
    /// 标题左边距（仅在左对齐模式下生效），默认 15
    public var titleLeadingMargin: CGFloat = 15 {
        didSet { titleLeadingConstraint?.constant = titleLeadingMargin }
    }

    // MARK: - 尺寸配置

    /// 选择器内容区高度，默认 230 pt
    public var pickerViewHeight: CGFloat = 230
    /// 顶部控制区域高度，默认 44 pt
    public var pickerHeaderViewHeight: CGFloat = 44 {
        didSet {
            pickerHeaderViewHeightConstraint?.constant = pickerHeaderViewHeight
            let defaultBtnH = min(44, pickerHeaderViewHeight)
            if cancelButtonHeight == 0 { cancelButtonHeightConstraint?.constant = defaultBtnH }
            if confirmButtonHeight == 0 { confirmButtonHeightConstraint?.constant = defaultBtnH }
        }
    }
    /// 取消按钮左边距
    public var cancelButtonLeftMargin: CGFloat = 0 {
        didSet { cancelButtonLeadingConstraint?.constant = cancelButtonLeftMargin }
    }
    /// 取消按钮宽度，默认 70 pt，设为 0 时隐藏
    public var cancelButtonWidth: CGFloat = 70 {
        didSet {
            cancelButtonWidthConstraint?.constant = cancelButtonWidth
            cancelButton.isHidden = (cancelButtonWidth == 0)
        }
    }
    /// 取消按钮高度
    public var cancelButtonHeight: CGFloat = 0 {
        didSet { cancelButtonHeightConstraint?.constant = cancelButtonHeight > 0 ? cancelButtonHeight : min(44, pickerHeaderViewHeight) }
    }
    /// 确定按钮右边距
    public var confirmButtonRightMargin: CGFloat = 0 {
        didSet { confirmButtonTrailingConstraint?.constant = -confirmButtonRightMargin }
    }
    /// 确定按钮宽度，默认 70 pt
    public var confirmButtonWidth: CGFloat = 70
    /// 确定按钮高度
    public var confirmButtonHeight: CGFloat = 0 {
        didSet { confirmButtonHeightConstraint?.constant = confirmButtonHeight > 0 ? confirmButtonHeight : min(44, pickerHeaderViewHeight) }
    }

    // MARK: - 行为控制

    /// 是否允许点击背景关闭弹窗，默认 YES
    public var shouldDismissWhenTapBackground = true

    // MARK: - 私有约束

    /// 标题水平居中约束（titleAlignment = center 时生效）
    private var titleCenterXConstraint: NSLayoutConstraint?
    /// 标题左边距约束（titleAlignment = left 时生效）
    private var titleLeadingConstraint: NSLayoutConstraint?
    /// 标题右边距约束（确保 title 不超出右边界）
    private var titleTrailingConstraint: NSLayoutConstraint?
    /// 顶部 header 区域高度约束（控制 pickerHeaderView 高度）
    private var pickerHeaderViewHeightConstraint: NSLayoutConstraint?
    /// 内容容器底部约束（用于动画控制弹出/隐藏）
    private var contentViewBottomConstraint: NSLayoutConstraint?
    /// 内容容器整体高度约束（pickerHeaderView + pickerView 的总高度）
    private var contentViewHeightConstraint: NSLayoutConstraint?
    /// 取消按钮左边距约束
    private var cancelButtonLeadingConstraint: NSLayoutConstraint?
    /// 取消按钮宽度约束
    private var cancelButtonWidthConstraint: NSLayoutConstraint?
    /// 取消按钮高度约束
    private var cancelButtonHeightConstraint: NSLayoutConstraint?
    /// 确定按钮右边距约束
    private var confirmButtonTrailingConstraint: NSLayoutConstraint?
    /// 确定按钮宽度约束
    private var confirmButtonWidthConstraint: NSLayoutConstraint?
    /// 确定按钮高度约束
    private var confirmButtonHeightConstraint: NSLayoutConstraint?

    // MARK: - 初始化

    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    public init() {
        super.init(frame: UIScreen.main.bounds)
        pickerViewHeight = 230
        pickerHeaderViewHeight = 44
        titleLeadingMargin = 15
        cancelButtonWidth = 70
        confirmButtonWidth = 70
        shouldDismissWhenTapBackground = true
        setupUI()
    }

    // MARK: - 生命周期

    /// 初始化并配置子视图结构（供子类重写使用）
    open func setupUI() {
        addSubview(backgroundDimView)
        addSubview(contentView)
        contentView.addSubview(pickerHeaderView)
        pickerHeaderView.addSubview(cancelButton)
        pickerHeaderView.addSubview(confirmButton)
        pickerHeaderView.addSubview(titleLabel)
        pickerHeaderView.addSubview(separatorView)

        [backgroundDimView, contentView, pickerHeaderView, cancelButton, confirmButton, titleLabel, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let defaultBtnH = min(44, pickerHeaderViewHeight)
        let cancelH = cancelButtonHeight > 0 ? cancelButtonHeight : defaultBtnH
        let confirmH = confirmButtonHeight > 0 ? confirmButtonHeight : defaultBtnH

        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: pickerHeaderViewHeight + pickerViewHeight)
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: totalContentViewHeight)
        contentViewBottomConstraint?.isActive = true

        cancelButtonLeadingConstraint = cancelButton.leadingAnchor.constraint(equalTo: pickerHeaderView.leadingAnchor, constant: cancelButtonLeftMargin)
        cancelButtonWidthConstraint = cancelButton.widthAnchor.constraint(equalToConstant: cancelButtonWidth)
        cancelButtonHeightConstraint = cancelButton.heightAnchor.constraint(equalToConstant: cancelH)

        confirmButtonTrailingConstraint = confirmButton.trailingAnchor.constraint(equalTo: pickerHeaderView.trailingAnchor, constant: -confirmButtonRightMargin)
        confirmButtonWidthConstraint = confirmButton.widthAnchor.constraint(equalToConstant: confirmButtonWidth)
        confirmButtonHeightConstraint = confirmButton.heightAnchor.constraint(equalToConstant: confirmH)

        titleCenterXConstraint = titleLabel.centerXAnchor.constraint(equalTo: pickerHeaderView.centerXAnchor)
        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: titleLeadingMargin)
        titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor, constant: -titleLeadingMargin)

        pickerHeaderViewHeightConstraint = pickerHeaderView.heightAnchor.constraint(equalToConstant: pickerHeaderViewHeight)

        NSLayoutConstraint.activate([
            backgroundDimView.topAnchor.constraint(equalTo: topAnchor),
            backgroundDimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundDimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundDimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentViewHeightConstraint!,
            pickerHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pickerHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pickerHeaderViewHeightConstraint!,
            cancelButtonLeadingConstraint!,
            cancelButton.centerYAnchor.constraint(equalTo: pickerHeaderView.centerYAnchor),
            cancelButtonWidthConstraint!,
            cancelButtonHeightConstraint!,
            confirmButtonTrailingConstraint!,
            confirmButton.centerYAnchor.constraint(equalTo: pickerHeaderView.centerYAnchor),
            confirmButtonWidthConstraint!,
            confirmButtonHeightConstraint!,
            titleLabel.centerYAnchor.constraint(equalTo: pickerHeaderView.centerYAnchor),
            titleCenterXConstraint!,
            titleTrailingConstraint!,
            separatorView.leadingAnchor.constraint(equalTo: pickerHeaderView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: pickerHeaderView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: pickerHeaderView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        backgroundDimView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        backgroundDimView.isUserInteractionEnabled = true
        backgroundDimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground)))

        contentView.backgroundColor = .white

        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.label, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        cancelButton.addTarget(self, action: #selector(handleCancelAction), for: .touchUpInside)

        confirmButton.setTitle("确定", for: .normal)
        confirmButton.setTitleColor(.label, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        confirmButton.addTarget(self, action: #selector(handleConfirmAction), for: .touchUpInside)

        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        separatorView.backgroundColor = .separator
    }

    /// 计算弹出视图的总高度，包括头部高度、选择器高度和底部安全区域高度
    private var totalContentViewHeight: CGFloat {
        pickerHeaderViewHeight + pickerViewHeight + safeAreaInsets.bottom
    }

    /// 根据 titleAlignment 更新标题约束
    private func updateTitleAlignment() {
        titleCenterXConstraint?.isActive = (titleAlignment == .center)
        titleLeadingConstraint?.isActive = (titleAlignment == .left)
        titleTrailingConstraint?.isActive = (titleAlignment == .right)
        titleLabel.textAlignment = titleAlignment
        pickerHeaderView.layoutIfNeeded()
    }

    // MARK: - 弹出控制

    /// 显示弹窗
    public func show() {
        showWithCompletion(nil)
    }

    /// 显示弹窗并执行完成回调
    /// - Parameter completion: 显示动画完成后的回调块（可为 nil）
    public func showWithCompletion(_ completion: (() -> Void)?) {
        guard let keyWindow = keyWindow else { return }
        keyWindow.addSubview(self)
        layoutIfNeeded()

        contentViewHeightConstraint?.constant = totalContentViewHeight
        contentViewBottomConstraint?.constant = pickerHeaderViewHeight + pickerViewHeight
        backgroundDimView.alpha = 0

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.contentViewBottomConstraint?.constant = 0
            self.backgroundDimView.alpha = 1
            self.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }

    /// 关闭弹窗
    public func dismiss() {
        dismissWithCompletion(nil)
    }

    /// 关闭弹窗并执行完成回调
    /// - Parameter completion: 关闭动画完成后的回调块（可为 nil）
    public func dismissWithCompletion(_ completion: (() -> Void)?) {
        var contentHeight = contentView.frame.height
        if contentHeight <= 0 { contentHeight = totalContentViewHeight }
        contentViewBottomConstraint?.constant = contentHeight

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.backgroundDimView.alpha = 0
            self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    public func setPickerHeaderViewHeight(_ height: CGFloat) {
        pickerHeaderViewHeight = height
        pickerHeaderViewHeightConstraint?.constant = height
    }

    public func setCancelButtonLeftMargin(_ margin: CGFloat) {
        cancelButtonLeftMargin = margin
        cancelButtonLeadingConstraint?.constant = margin
    }

    public func setCancelButtonWidth(_ width: CGFloat) {
        cancelButtonWidth = width
        cancelButtonWidthConstraint?.constant = width
    }

    public func setConfirmButtonRightMargin(_ margin: CGFloat) {
        confirmButtonRightMargin = margin
        confirmButtonTrailingConstraint?.constant = -margin
    }

    public func setConfirmButtonWidth(_ width: CGFloat) {
        confirmButtonWidth = width
        confirmButtonWidthConstraint?.constant = width
    }

    // MARK: - 事件

    /// 处理背景遮罩的点击事件（根据 shouldDismissWhenTapBackground 决定是否关闭）
    @objc private func didTapBackground() {
        if shouldDismissWhenTapBackground { dismiss() }
    }

    /// 取消按钮点击事件处理（供子类复写或自定义）
    @objc open func handleCancelAction() {
        dismiss()
    }

    /// 确定按钮点击事件处理（供子类复写或自定义）
    @objc open func handleConfirmAction() {
        dismiss()
    }

    /// 添加自定义子视图到选择器内容区
    @objc open func addSubViewToPicker(_ customView: UIView) {
        contentView.addSubview(customView)
    }

    // MARK: - 辅助

    /// 获取当前应用的主窗口（iOS 13+ 多场景）
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}
