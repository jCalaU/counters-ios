//
//  CountersListViewController.swift
//  Counters
//
//

import UIKit

protocol CountersListViewControllerPresenter {
    var viewModel: CountersListView.ViewModel { get }
    var viewEmptyModel: CountersListEmptyView.ViewModel { get }
    func display(_ view: CounterAlertPresenter)
}

class CountersListViewController: UIViewController {

    // MARK: - Properties

    lazy var innerView = CountersListView()
    private lazy var innerEmptyView = CountersListEmptyView()
    private let presenter: CountersListViewControllerPresenter
    private let barPresenter : CountersBarPresenter
    private let refreshControl = UIRefreshControl()

    // MARK: - Initialization

    init(presenter: CountersListViewControllerPresenter, barPresenter: CountersBarPresenter) {
        self.presenter = presenter
        self.barPresenter = barPresenter
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
        self.getAllCountersFromServer()
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
        innerView.delegate = self
        
        innerEmptyView.configure(with: presenter.viewEmptyModel)
    }
            
    func setupLayout() {
        setupBarControler()
        setupRefreshControl()
    }
}

    // MARK: - Extension

private extension CountersListViewController {
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshCountersData(_:)), for: .valueChanged)
        innerView.tableView.addSubview(refreshControl)
    }
    
    @objc func refreshCountersData(_ sender: Any) {
        getAllCountersFromServer()
    }
    
    func setupBarControler() {
        self.barPresenter.setupActions(self)
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
        
        let retryTitle = "COUNTERALERTPRESENTER_RETRY".localized
        let dismissTitle = "COUNTERALERTPRESENTER_DISMISS".localized
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
        self.barPresenter.setBarBottomTitle(self)
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
        
        let dismissTitle = "COUNTERALERTPRESENTER_DISMISS".localized
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
        self.barPresenter.enableEditButton(false)
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
    }
    
    func setEmptyState() {
        
        self.innerEmptyView.updateTexts("COUNTERLIST_EMPTY_TITLE".localized,
                                        "COUNTERLIST_EMPTY_SUBTITLE".localized,
                                        "COUNTERLIST_EMPTY_BUTTON".localized,
                                        self.barPresenter.addButtonPressed)
        self.innerView.tableView.backgroundView = self.innerEmptyView
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
        
        self.innerView.currentState = .empty
        self.barPresenter.enableEditButton(false)
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

        self.barPresenter.enableEditButton(false)

        self.innerView.countersdb = self.getCounterCellPresenter()
        if self.innerView.countersdb.count != 0 {
            self.innerView.tableView.backgroundView = nil
            self.innerView.currentState = .content
            self.barPresenter.enableEditButton(true)
        }

        self.updateViewState()
    }
    
    func setContentState() {
        self.innerView.currentState = .content
        self.innerView.activityIndicator.stopAnimating()
        
        self.innerView.tableView.backgroundView = nil
        self.navigationItem.searchController?.searchBar.isUserInteractionEnabled = true
        self.barPresenter.enableEditButton(true)

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
        self.barPresenter.deleteButton.isEnabled = enable
        self.barPresenter.shareButton.isEnabled = enable
    }
    
    func setFilteringState(_ enable: Bool) {
        self.innerEmptyView.updateTexts("".localized,
                                        "COUNTERLIST_NORESULTS_TITLE".localized,
                                        "".localized,
                                        self.barPresenter.addButtonPressed)

        self.innerEmptyView.hideButton(enable)
        self.innerView.tableView.backgroundView = enable ? self.innerEmptyView : nil
    }
}
