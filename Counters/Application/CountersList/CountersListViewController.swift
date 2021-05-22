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
    
    let barController: CountersBarController

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
        
        self.title = NSLocalizedString("APP_NAME", comment: "")
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
    }
        
    func setupLayout() {
        navigationController?.navigationBar.prefersLargeTitles = true
        setupBarControler()
    }
}

    // MARK: - Extension

private extension CountersListViewController {
    
    func setupBarControler() {
        navigationController?.isToolbarHidden = false
        navigationController?.isNavigationBarHidden = false
                        
        barController.editAction = { [weak self] editing in
            self?.setEditing(editing, animated: true)
            self?.navigationItem.searchController?.searchBar.isUserInteractionEnabled = !editing
            self?.setupBars()
        }
        setupBars()
    }
    
    func setupBars() {
        barController.setupBars(self.isEditing)
        toolbarItems = barController.toolbarItems
        navigationItem.leftBarButtonItem = barController.leftBarButtonItem
        navigationItem.rightBarButtonItem = barController.rightBarButtonItem
    }
}
