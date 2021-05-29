//
//  CountersBarPresenter.swift
//  Counters
//
//

import UIKit

final class CountersBarPresenter {
    
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
    }
    
    @objc func addButtonPressed() {
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

extension CountersBarPresenter {
    
    func setupActions(_ controller: CountersListViewController) {
        
        // Add counter action
        addAction = {
            let presenter = CountersCreateViewPresenter()
            let viewController = CountersCreateViewController(presenter: presenter)
            viewController.countersCreateDelegate = controller
            controller.navigationController?.present(UINavigationController(rootViewController: viewController), animated: true)
        }
        
        // Delete counter action
        deleteAction = {
            guard let indexPaths = controller.innerView.tableView.indexPathsForSelectedRows else { return }
            
            // Cancel Action
            let actionSheetController: UIAlertController = UIAlertController(title: "".localized, message: "", preferredStyle: .actionSheet)

            let cancelActionButton = UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
                Logger("Cancel")
            }
            actionSheetController.addAction(cancelActionButton)

            // Delete Action
            let selectedRows = indexPaths.count
            let deleteActionTitle = (selectedRows == 1) ? String(format: "COUNTERLIST_ALERT_DELETE_COUNTER".localized, selectedRows) : String(format: "COUNTERLIST_ALERT_DELETE_COUNTERS".localized, selectedRows)
            
            let deleteActionButton = UIAlertAction(title: deleteActionTitle, style: .destructive) { _ in
                DispatchQueue.main.async { self.deleteCounter(controller) }
            }
            actionSheetController.addAction(deleteActionButton)
            
            controller.present(actionSheetController, animated: true, completion: nil)
        }
        
        // SelectAll counter action
        selectAllAction = {
            let totalRows = controller.innerView.tableView.numberOfRows(inSection: 0)
                
            for row in 0..<totalRows {
                controller.innerView.tableView.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
            }
            controller.enableCellOptions(true)
        }
        
        // Share counter action
        shareAction = {
            guard let indexPaths = controller.innerView.tableView.indexPathsForSelectedRows else { return }
            var countersTxt = [String]()
            for indexPath in indexPaths {
                guard let cell = controller.innerView.tableView.cellForRow(at: NSIndexPath(row: indexPath.row, section: indexPath.section) as IndexPath) as? CounterTableViewCell else { return }
                
                let txt = cell.countLabel.text! + " x " + cell.titleLabel.text!
                countersTxt.append(txt)
            }
            let activityViewController = UIActivityViewController(activityItems: countersTxt, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = controller.innerView

            controller.present(activityViewController, animated: true, completion: nil)
        }
        
        controller.navigationItem.searchController = controller.innerView.searchController
        controller.navigationController?.navigationBar.prefersLargeTitles = true
        controller.navigationController?.isToolbarHidden = false
        controller.navigationController?.isNavigationBarHidden = false

        // Edit counter action
        editAction = { editing in
            controller.innerView.tableView.setEditing(editing, animated: true)
            controller.navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
            self.setupBars(controller)
        }
        
        self.setupBars(controller)
    }
    
    func setupBars(_ controller: CountersListViewController) {
        setupNavigationBar(controller.innerView.tableView.isEditing)
        setupToolBar(controller.innerView.tableView.isEditing)

        setBarBottomTitle(controller)

        controller.toolbarItems = toolbarItems
        controller.navigationItem.leftBarButtonItem = leftBarButtonItem
        controller.navigationItem.rightBarButtonItem = rightBarButtonItem
        controller.navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    func setBarBottomTitle(_ controller: CountersListViewController) {
        
        guard !controller.innerView.tableView.isEditing else {
            bottomBarTitleLabel.text = ""
            return
        }
        
        guard controller.innerView.countersdb.count != 0 else {
            bottomBarTitleLabel.text = ""
            return
        }
        
        var sumCounters : Int64 = 0
        for counter in controller.innerView.countersdb {
            sumCounters += counter.countersdb.count
        }
        
        let bottomTitle = controller.innerView.countersdb.count == 1 ? "COUNTERLIST_BOTTOM_TITLE_ITEM".localized : "COUNTERLIST_BOTTOM_TITLE_ITEMS".localized
        let text = String(format: bottomTitle, controller.innerView.countersdb.count, sumCounters)
        
        bottomBarTitleLabel.text = text
        bottomBarTitleLabel.sizeToFit()
    }
        
    func enableEditButton(_ enable: Bool) {
        editButton.isEnabled = enable
    }
}

private extension CountersBarPresenter {
    
    func setupNavigationBar(_ editing: Bool) {
        leftBarButtonItem = editing ? doneButton : editButton
        rightBarButtonItem = editing ? selectAllButton : nil
    }
    
    func deleteCounter(_ controller: CountersListViewController) {
        guard let indexPaths = controller.innerView.tableView.indexPathsForSelectedRows else { return }
        for indexPath in indexPaths {
            guard let cell = controller.innerView.tableView.cellForRow(at: NSIndexPath(row: indexPath.row, section: indexPath.section) as IndexPath) as? CounterTableViewCell else { return }

            guard let idCounter = cell.counterId else { return }
            let params:[String: Any] = ["id" : idCounter]
                    
            let completion = HTTPResponse.checkResponse(.delCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

                DispatchQueue.main.async {
                    guard isSuccess else {
                        let title = String(format: "COUNTERSLIST_FAIL_DELETE_MESSAGE".localized, cell.titleLabel.text!)
                        controller.showErrorMessageSimple(title, error, controller)
                        return
                    }
                    
                    controller.setStatePresenterContentState()
                }
            })

            HTTPClient.sharedInstance.userRequestToServer(params,
                                                          httpMethod: Method.DELETE.rawValue,
                                                          endPoint: addCounterEndpoint,
                                                          onCompletion:completion)
        }
    }
    
    func setupToolBar(_ editing: Bool) {
        toolbarItems = editing ?
            [deleteButton, .flexibleSpace, shareButton] :
            [.flexibleSpace, .customView(bottomBarTitleLabel), .flexibleSpace, addButton]
    }
    
    func setupEditingToolBar() {
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
