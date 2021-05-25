//
//  CountersCreateViewController.swift
//  Counters
//
//

import UIKit

protocol CountersCreateViewControllerPresenter {
    var viewModel: CountersCreateView.ViewModel { get }
}

protocol CountersCreateViewControllerDelegate {
    func addCounter(_ viewController: CountersCreateViewController)
}

class CountersCreateViewController: UIViewController {

    // MARK: - Properties

    var innerView = CountersCreateView()
    
    private let presenter: CountersCreateViewControllerPresenter

    private var saveBarButton: UIBarButtonItem?

    var countersCreateDelegate: CountersCreateViewControllerDelegate?
    
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
        
        self.title = "COUNTERSCREATE_TITLE".localized
        
        setupLayout()
        innerView.configure(with: presenter.viewModel)
        innerView.delegate = self
    }
        
    @objc private func dismissAction() {
        dismiss(animated: true)
    }
    
    @objc private func savePressed() {
        countersCreateDelegate?.addCounter(self)
    }
    
    func setupLayout() {
        navigationController?.isToolbarHidden = false
        navigationController?.isNavigationBarHidden = false
        setup()
    }
}

    // MARK: - Extension

extension CountersCreateViewController: CounterCreateViewDelegate {
    func presentCountersExample() {
        let presenter = CountersExampleViewPresenter()
        let viewController = CountersExampleViewController(presenter: presenter)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CountersCreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var text = textField.text else {
            return false
            
        }
        text = (text as NSString).replacingCharacters(in: range, with: string)
        
        saveBarButton?.isEnabled = !text.isEmpty
        return true
    }
}

private extension CountersCreateViewController {
    func setup() {
        setupNavigationBar()
        setupTextField()
    }
    
    func setupTextField() {
        innerView.textField.delegate = self
        innerView.textField.placeholder = "COUNTERSCREATE_PLACEHOLDER_TXT".localized
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissAction)
        )
        saveBarButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(savePressed)
        )
        saveBarButton?.isEnabled = false
        
        navigationItem.rightBarButtonItem = saveBarButton
    }
}
