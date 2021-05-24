//
//  CountersCreateViewController.swift
//  Counters
//
//

import UIKit

protocol CountersCreateViewControllerPresenter {
    var viewModel: CountersCreateView.ViewModel { get }
}

class CountersCreateViewController: UIViewController {

    // MARK: - Properties

    private lazy var innerView = CountersCreateView()
    
    private let presenter: CountersCreateViewControllerPresenter

    // MARK: - Initialization

    init(presenter: CountersCreateViewControllerPresenter) {
        self.presenter = presenter
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
        navigationController?.isToolbarHidden = false
        navigationController?.isNavigationBarHidden = false
    }
}

    // MARK: - Extension

private extension CountersCreateViewController {
}
