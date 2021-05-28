//
//  CountersBarController.swift
//  Counters
//
//

import UIKit

final class CountersBarController {
    
    // MARK: - Properties
    
    private(set) var rightBarButtonItem: UIBarButtonItem?
    private(set) var leftBarButtonItem: UIBarButtonItem?
    private(set) var toolbarItems: [UIBarButtonItem]?

    private(set) lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    private(set) lazy var deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
    private(set) lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
    private(set) lazy var editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    private(set) lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    private(set) lazy var selectAllButton =  UIBarButtonItem(
        title: "Select All",
        style: .plain,
        target: self,
        action: #selector(selectAllButtonPressed)
    )

    private(set) lazy var bottomBarTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    var addAction: (() -> Void)?
    var editAction: ((Bool) -> Void)?
    var deleteAction: (() -> Void)?
    var selectAllAction: (() -> Void)?
    var shareAction: (() -> Void)?
    
    // MARK: - Internal Methods
    
    func setBarTitle(_ title: String?) {
        bottomBarTitleLabel.text = title
        bottomBarTitleLabel.sizeToFit()
    }
        
    @objc private func editButtonPressed() {
        deleteButton.isEnabled = false
        shareButton.isEnabled = false
        editAction?(true)
    }
    
    @objc private func doneButtonPressed() {
        editAction?(false)
    }
    
    @objc private func selectAllButtonPressed() {
        selectAllAction?()
        enableCellOptions(true)
    }
    
    @objc private func addButtonPressed() {
        addAction?()
    }
    
    @objc private func deleteButtonPressed() {
        deleteAction?()
    }
    
    @objc private func shareButtonPressed() {
        shareAction?()
    }
}

// MARK: - Implementation

extension CountersBarController {
    func setupBars(_ editing: Bool) {
        setupNavigationBar(editing)
        setupToolBar(editing)
    }
    
    func enableEditButton(_ enable: Bool) {
        editButton.isEnabled = enable
    }
    
    private func setupNavigationBar(_ editing: Bool) {
        leftBarButtonItem = editing ? doneButton : editButton
        rightBarButtonItem = editing ? selectAllButton : nil
    }
    
    private func setupToolBar(_ editing: Bool) {
        toolbarItems = editing ?
            [deleteButton, .flexibleSpace, shareButton] :
            [.flexibleSpace, .customView(bottomBarTitleLabel), .flexibleSpace, addButton]
    }
    
    private func setupEditingToolBar() {
        toolbarItems = [deleteButton]
    }
}

private extension UIBarButtonItem {
    static var flexibleSpace: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    static func customView(_ view: UIView) -> UIBarButtonItem {
        UIBarButtonItem(customView: view)
    }
}


// MARK: - Extension

extension CountersBarController: CounterListViewDelegate {
    func enableCellOptions(_ enable: Bool) {
        deleteButton.isEnabled = enable
        shareButton.isEnabled = enable
    }
}
