//
//  CountersExampleViewController.swift
//  Counters
//
//

import UIKit

protocol CountersExampleViewControllerPresenter {
    var viewModel: CountersExampleView.ViewModel { get }
}

class CountersExampleViewController: UIViewController {

    // MARK: - Properties

    private lazy var innerView = CountersExampleView()
    
    private let presenter: CountersExampleViewControllerPresenter
    
    // MARK: - Initialization

    init(presenter: CountersExampleViewControllerPresenter) {
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
        
        self.title = "COUNTERSEXAMPLE_TITLE".localized
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
    }
    
    func setupLayout() {
        navigationController?.isToolbarHidden = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backItem?.title = "COUNTERSCREATE_TITLE".localized
        setup()
    }
}

    // MARK: - Extension

private extension CountersExampleViewController {
    func setup() {
    }
}
