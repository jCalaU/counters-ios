//
//  CountersListViewController.swift
//  Counters
//
//

import UIKit

protocol CountersListViewControllerPresenter {
    var viewModel: CountersListView.ViewModel { get }
    var viewEmptyModel: CountersListEmptyView.ViewModel { get }
    func display(_ view: CountersAlertPresenter)
}

class CountersListViewController: UIViewController {

    // MARK: - Properties

    lazy var innerView = CountersListView()
    lazy var innerEmptyView = CountersListEmptyView()
    private let presenter: CountersListViewControllerPresenter
    private let barPresenter : CountersBarPresenter
    private let refreshControl = UIRefreshControl()
    private let statePresenter = CountersStatePresenter()

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
        self.statePresenter.countersListViewController = self
        self.statePresenter.barPresenter = self.barPresenter
        self.statePresenter.countersListpresenter = self.presenter
        
        self.statePresenter.setLoadingState()
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
    
    func setStatePresenterContentState() {
        statePresenter.setContentState()
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

    // MARK: - Extension Network
extension CountersListViewController {
    
    func getAllCountersFromServer() {
        
        let completion = HTTPResponse.checkResponse(.getAllCounters, onCompletion: {(isSuccess: Bool, countersArray: [CNApiCounters], error: Error?) in
            self.refreshControl.endRefreshing()
            guard isSuccess else {
                self.showErrorMessageSimple("COUNTERSLIST_FAIL_RELOAD_MESSAGE".localized, error, self)
                self.statePresenter.setErrorState()
                return
            }

            self.statePresenter.setContentState()
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

            self.statePresenter.setContentState()
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
        
        let dismissTitle = "COUNTERSALERTPRESENTER_DISMISS".localized
        self.presenter.display(.error(
                            title: title,
                            message: alertMessage,
                            actionTitles: [dismissTitle],
                            actions: [],
                            viewController: viewController
        ))
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
