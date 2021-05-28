//
//  CountersListViewController.swift
//  Counters
//
//

import UIKit

protocol CountersListViewControllerPresenter {
    var viewModel: CountersListView.ViewModel { get }
    var viewEmptyModel: CountersListEmptyView.ViewModel { get }
    func display(_ view: CounterAlertController)
}

class CountersListViewController: UIViewController {

    // MARK: - Properties

    private lazy var innerView = CountersListView()

    private lazy var innerEmptyView = CountersListEmptyView()
    
    private let presenter: CountersListViewControllerPresenter
    
    private let barController : CountersBarController

    private let refreshControl = UIRefreshControl()

    // MARK: - Initialization

    init(presenter: CountersListViewControllerPresenter, barController: CountersBarController) {
        self.presenter = presenter
        self.barController = barController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = innerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "APP_NAME".localized

        self.setLoadingState()
        
        // Get All Counters
        getAllCountersFromServer()
        
        self.barController.addAction = presentCountersCreate
        self.barController.deleteAction = askDeleteCounter
        self.barController.selectAllAction = selectAllCounter
        self.barController.shareAction = shareCounter
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
        innerView.delegate = self
        
        innerEmptyView.configure(with: presenter.viewEmptyModel)
        
        refreshControl.addTarget(self, action: #selector(refreshCountersData(_:)), for: .valueChanged)
        innerView.tableView.addSubview(refreshControl)
        
        navigationItem.searchController = innerView.searchController
    }
        
    @objc private func refreshCountersData(_ sender: Any) {
        getAllCountersFromServer()
    }

    
    private func shareCounter() {
        
        guard let indexPaths = innerView.tableView.indexPathsForSelectedRows else { return }
        var countersTxt = [String]()
        for indexPath in indexPaths {
            guard let cell = self.innerView.tableView.cellForRow(at: NSIndexPath(row: indexPath.row, section: indexPath.section) as IndexPath) as? CounterTableViewCell else { return }
            
            let txt = cell.countLabel.text! + " x " + cell.titleLabel.text!
            countersTxt.append(txt)
        }
        let activityViewController = UIActivityViewController(activityItems: countersTxt, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.innerView

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func selectAllCounter() {
        let totalRows = innerView.tableView.numberOfRows(inSection: 0)
            
        for row in 0..<totalRows {
            innerView.tableView.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
        }
        enableCellOptions(true)
    }
    
    private func presentCountersCreate() {
        let presenter = CountersCreateViewPresenter()
        let viewController = CountersCreateViewController(presenter: presenter)
        viewController.countersCreateDelegate = self
        navigationController?.present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    private func askDeleteCounter() {
        guard let indexPaths = innerView.tableView.indexPathsForSelectedRows else { return }
        
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
            DispatchQueue.main.async { self.deleteCounter() }
        }
        actionSheetController.addAction(deleteActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    private func deleteCounter() {
        guard let indexPaths = innerView.tableView.indexPathsForSelectedRows else { return }
        for indexPath in indexPaths {
            guard let cell = self.innerView.tableView.cellForRow(at: NSIndexPath(row: indexPath.row, section: indexPath.section) as IndexPath) as? CounterTableViewCell else { return }

            guard let idCounter = cell.counterId else { return }
            let params:[String: Any] = ["id" : idCounter]
                    
            let completion = HTTPResponse.checkResponse(.delCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in

                DispatchQueue.main.async {
                    guard isSuccess else {
                        let title = String(format: "COUNTERSLIST_FAIL_DELETE_MESSAGE".localized, cell.titleLabel.text!)
                        self.showErrorMessageSimple(title, error, self)
                        return
                    }
                    
                    self.setContentState()
                }
            })

            HTTPClient.sharedInstance.userRequestToServer(params,
                                                          httpMethod: Method.DELETE.rawValue,
                                                          endPoint: addCounterEndpoint,
                                                          onCompletion:completion)
        }
    }
    
    func setupLayout() {
        setupBarControler()
    }
}

    // MARK: - Extension

private extension CountersListViewController {
    func setupBarControler() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false
        navigationController?.isNavigationBarHidden = false
        
        self.barController.editAction = { [weak self] editing in
            self?.innerView.tableView.setEditing(editing, animated: true)
            self?.navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
            self?.setupBars()
        }
        setupBars()
    }
    
    func setupBars() {
        self.barController.setupBars(innerView.tableView.isEditing)
        let bottomTitle = getBarBottomTitle()
        self.barController.setBarTitle(bottomTitle)

        toolbarItems = self.barController.toolbarItems
        navigationItem.leftBarButtonItem = self.barController.leftBarButtonItem
        navigationItem.rightBarButtonItem = self.barController.rightBarButtonItem
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    func getBarBottomTitle() -> String {
        
        guard !innerView.tableView.isEditing else {
            return ""
        }
        
        guard self.innerView.countersdb.count != 0 else {
            return ""
        }
        
        var sumCounters : Int64 = 0
        for counter in self.innerView.countersdb {
            sumCounters += counter.countersdb.count
        }
        
        let bottomTitle = self.innerView.countersdb.count == 1 ? "COUNTERLIST_BOTTOM_TITLE_ITEM".localized : "COUNTERLIST_BOTTOM_TITLE_ITEMS".localized
        let text = String(format: bottomTitle, self.innerView.countersdb.count, sumCounters)
        
        return text
    }
}

// MARK: - CounterCellPresenterDelegate
extension CountersListViewController : CounterCellPresenterDelegate {
    
    func reloadTableView() {
        self.setContentState()
    }
    
    func showErrorMessage(_ title:String, _ error:Error?, _ retryAction: @escaping (() -> Void)) {
        var alertMessage = "Error".localized
        if let err = error {
            alertMessage = err.localizedDescription
        }
        
        let retryTitle = "COUNTERALERTCONTROLLER_RETRY".localized
        let dismissTitle = "COUNTERALERTCONTROLLER_DISMISS".localized
        self.presenter.display(.error(
                            title: title,
                            message: alertMessage,
                            actionTitles: [retryTitle, dismissTitle],
                            actions: [retryAction],
                            viewController: self
        ))
    }
}

    // MARK: - Extension Network
private extension CountersListViewController {
    
    func updateViewState() {
        if self.innerView.isFiltering {
            self.innerView.filterContentForSearchText(self.innerView.searchController.searchBar.text!)
        }
        self.barController.setBarTitle(self.getBarBottomTitle())
        self.innerView.tableView.reloadData()
    }
    
    func getCounterCellPresenter() -> [CounterCellPresenter] {
    
        var counterCellArray = [CounterCellPresenter]()
        let fetchedObjects = CNCoreData.sharedInstance.getCNCounters()
        for obj in fetchedObjects {
            let counterCell = CounterCellPresenter(obj)
            counterCell.delegate = self
            counterCellArray.append(counterCell)
        }
        
        return counterCellArray
    }
    
    func getAllCountersFromServer() {
        
        let completion = HTTPResponse.checkResponse(.getAllCounters, onCompletion: {(isSuccess: Bool, countersArray: [CNApiCounters], error: Error?) in
            self.refreshControl.endRefreshing()
            guard isSuccess else {
                self.showErrorMessageSimple("COUNTERSLIST_FAIL_RELOAD_MESSAGE".localized, error, self)
                self.setErrorState()
                return
            }

            self.setContentState()
        })

        HTTPClient.sharedInstance.userRequestToServer(nil,
                                                      httpMethod: Method.GET.rawValue,
                                                      endPoint: getCountersEndpoint,
                                                      onCompletion:completion)
    }
}

// MARK: - Extension

extension CountersListViewController: CountersCreateViewControllerDelegate {
    
    func addCounter(_ viewController: CountersCreateViewController) {
        
        guard let title = viewController.innerView.textField.text else { return }
        let params:[String: Any] = [
            "title"       : title]
        
        viewController.innerView.activityIndicator.startAnimating()
        
        // Start request
        let completion = HTTPResponse.checkResponse(.addCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters], error: Error?) in
            viewController.innerView.activityIndicator.stopAnimating()
            
            guard isSuccess else {
                self.showErrorMessageSimple("COUNTERSCREATE_FAIL_MESSAGE".localized, error, viewController)
                return
            }

            self.setContentState()
            viewController.dismiss(animated: true)
        })
        
        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
    }
    
    func showErrorMessageSimple(_ title: String, _ error:Error?, _ viewController: UIViewController) {
        var alertMessage = "Error".localized
        if let err = error {
            alertMessage = err.localizedDescription
        }
        
        let dismissTitle = "COUNTERALERTCONTROLLER_DISMISS".localized
        self.presenter.display(.error(
                            title: title,
                            message: alertMessage,
                            actionTitles: [dismissTitle],
                            actions: [],
                            viewController: viewController
        ))
    }
}



extension CountersListViewController: CountersListState {
    
    func setLoadingState() {
        self.innerView.currentState = .loading
        self.innerView.activityIndicator.startAnimating()
        self.barController.enableEditButton(false)
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
    }
    
    func setEmptyState() {
        
        self.innerEmptyView.updateTexts("COUNTERLIST_EMPTY_TITLE".localized,
                                        "COUNTERLIST_EMPTY_SUBTITLE".localized,
                                        "COUNTERLIST_EMPTY_BUTTON".localized,
                                        self.presentCountersCreate)
        self.innerView.tableView.backgroundView = self.innerEmptyView
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
        
        self.innerView.currentState = .empty
        self.barController.enableEditButton(false)
    }
    
    func setErrorState() {
        
        self.innerEmptyView.updateTexts("COUNTERLIST_ERROR_TITLE".localized,
                                        "COUNTERLIST_ERROR_SUBTITLE".localized,
                                        "COUNTERLIST_ERROR_BUTTON".localized,
                                        self.getAllCountersFromServer)
        self.innerView.tableView.backgroundView = self.innerEmptyView
        
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
        
        self.innerView.currentState = .error
        self.innerView.activityIndicator.stopAnimating()

        self.barController.enableEditButton(false)

        self.innerView.countersdb = self.getCounterCellPresenter()
        if self.innerView.countersdb.count != 0 {
            self.innerView.tableView.backgroundView = nil
            self.innerView.currentState = .content
            self.barController.enableEditButton(true)
        }

        self.updateViewState()
    }
    
    func setContentState() {
        self.innerView.currentState = .content
        self.innerView.activityIndicator.stopAnimating()
        
        self.innerView.tableView.backgroundView = nil
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = true
        self.barController.enableEditButton(true)

        self.innerView.countersdb = self.getCounterCellPresenter()
        if self.innerView.countersdb.count == 0 {
            self.setEmptyState()
        }

        self.updateViewState()
    }
}

// MARK: - Extension

extension CountersListViewController: CounterListViewDelegate {
    func enableCellOptions(_ enable: Bool) {
        self.barController.deleteButton.isEnabled = enable
        self.barController.shareButton.isEnabled = enable
    }
    
    func setFilteringState(_ enable: Bool) {
        self.innerEmptyView.updateTexts("".localized,
                                        "COUNTERLIST_NORESULTS_TITLE".localized,
                                        "".localized,
                                        self.presentCountersCreate)

        self.innerEmptyView.hideButton(enable)
        self.innerView.tableView.backgroundView = enable ? self.innerEmptyView : nil
    }
}
