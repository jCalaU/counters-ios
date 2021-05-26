//
//  CountersListViewController.swift
//  Counters
//
//

import UIKit

protocol CountersListViewControllerPresenter {
    var viewModel: CountersListView.ViewModel { get }
}

class CountersListViewController: UIViewController {

    // MARK: - Properties

    private lazy var innerView = CountersListView()
    
    private let presenter: CountersListViewControllerPresenter
    
    private let barController : CountersBarController

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
        
        // Get All Counters
        getAllCountersFromServer()
        
        barController.addAction = presentCountersCreate
        setupLayout()
        innerView.configure(with: presenter.viewModel)
    }
        
    private func presentCountersCreate() {
        let presenter = CountersCreateViewPresenter()
        let viewController = CountersCreateViewController(presenter: presenter)
        viewController.countersCreateDelegate = self
        navigationController?.present(UINavigationController(rootViewController: viewController), animated: true)
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
        
        barController.editAction = { [weak self] editing in
            self?.innerView.tableView.setEditing(editing, animated: true)
            self?.navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
            self?.setupBars()
        }
        setupBars()
    }
    
    func setupBars() {
        barController.setupBars(innerView.tableView.isEditing)
        toolbarItems = barController.toolbarItems
        navigationItem.leftBarButtonItem = barController.leftBarButtonItem
        navigationItem.rightBarButtonItem = barController.rightBarButtonItem
    }
}

// MARK: - CounterCellPresenterDelegate
extension CountersListViewController : CounterCellPresenterDelegate {
    
    func reloadTableView() {
        self.innerView.countersdb = self.getCounterCellPresenter()
        self.innerView.currentState = (self.innerView.countersdb.count != 0) ? .content : .empty
        if self.innerView.isFiltering {
            self.innerView.filterContentForSearchText(self.innerView.searchController.searchBar.text!)
        }
        self.innerView.tableView.reloadData()
    }
}

    // MARK: - Extension Network
private extension CountersListViewController {

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
        
        let completion = HTTPResponse.checkResponse(.getAllCounters, onCompletion: {(isSuccess: Bool, countersArray: [CNApiCounters]) in
            self.innerView.activityIndicator.stopAnimating()
            guard isSuccess else {
                self.innerView.currentState = .error
                self.innerView.tableView.reloadData()
                return
            }

            self.innerView.countersdb = self.getCounterCellPresenter()
            self.innerView.currentState = (self.innerView.countersdb.count != 0) ? .content : .empty
            self.innerView.tableView.reloadData()
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
        
        let completion = HTTPResponse.checkResponse(.addCounter, onCompletion:{( isSuccess:Bool, countersArray:[CNApiCounters]) in

            viewController.innerView.activityIndicator.stopAnimating()

            guard isSuccess else {
                // show message error
            return
            }

            self.innerView.countersdb = self.getCounterCellPresenter()
            self.innerView.currentState = (self.innerView.countersdb.count != 0) ? .content : .empty
            self.innerView.tableView.reloadData()
            
            viewController.dismiss(animated: true)
        })
        
        HTTPClient.sharedInstance.userRequestToServer(params,
                                                      httpMethod: Method.POST.rawValue,
                                                      endPoint: addCounterEndpoint,
                                                      onCompletion:completion)
    }
}
