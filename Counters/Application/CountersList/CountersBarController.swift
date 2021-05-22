//
//  CountersBarController.swift
//  Counters
//
//

import UIKit

final class CountersBarController {
    private(set) var rightBarButtonItem: UIBarButtonItem?
    private(set) var leftBarButtonItem: UIBarButtonItem?
    private(set) var toolbarItems: [UIBarButtonItem]?
    
    // MARK: - ToolBar not editing
    private(set) lazy var bottomBarTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    private(set) lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    
    // MARK: - ToolBar editing
    private(set) lazy var deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
    private(set) lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
    
    // MARK: - NavigationBar not editing
    private(set) lazy var editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    
    // MARK: - NavigationBar editing
    private(set) lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    private(set) lazy var selectAllButton =  UIBarButtonItem(
        title: "Select All",
        style: .plain,
        target: self,
        action: #selector(selectAllButtonPressed)
    )
    
    private let addAction: () -> Void
    var editAction: ((Bool) -> Void)?
    
    init(addAction: @escaping () -> Void) {
        self.addAction = addAction
    }
    
    func setBarTitle(_ title: String?) {
        bottomBarTitleLabel.text = title
        bottomBarTitleLabel.sizeToFit()
    }
    
    @objc private func editButtonPressed() {
        editAction?(true)
    }
    
    @objc private func doneButtonPressed() {
        editAction?(false)
    }
    
    @objc private func selectAllButtonPressed() {
        
    }
    
    @objc private func addButtonPressed() {
        addAction()
    }
    
    @objc private func deleteButtonPressed() {
        
    }
    
    @objc private func shareButtonPressed() {
        
    }
}

extension CountersBarController {
    func setupBars(_ editing: Bool) {
        setupNavigationBar(editing)
        setupToolBar(editing)
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
