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
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
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
