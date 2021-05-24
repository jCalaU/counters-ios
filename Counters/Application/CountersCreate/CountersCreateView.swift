//
//  CountersCreateView.swift
//  Counters
//
//

import UIKit

internal final class CountersCreateView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let description: NSAttributedString
    }
    
    // MARK: - Properties

    private let descriptionLabel = UILabel()
    private let containerView = UIView()
    let textField = UITextField()
    let activityIndicator = UIActivityIndicatorView()
    let stackView = UIStackView()

    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: ViewModel) {
        descriptionLabel.attributedText = viewModel.description
    }
}

    // MARK: - Private Constants

private extension CountersCreateView {
    enum Constants {
        static let spacing: CGFloat = 24
        static let stackViewTopMargin: CGFloat = 45
    }
    
    enum Font {
        static let kern: CGFloat = 0.34
        static let description = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    enum Shadow {
        static let opacity: Float = 1
        static let radius: CGFloat = 16
        static let offset = CGSize(width: 0, height: 8)
        static let color = UIColor(white: 0, alpha: 0.1).cgColor
    }
}

    // MARK: - Private Implementation

private extension CountersCreateView {
    func setup() {
        backgroundColor = .background

        setupDescriptionLabel()
        setupContainerView()
        setupStackView()
        setupTextField()
        setupActivityIndicator()
        setupViewHierarchy()
        setupConstraints()
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font.description)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 9
    }
    
    func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
    }
    
    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .preferredFont(forTextStyle: .body)
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
    }
    
    func setupViewHierarchy() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(activityIndicator)
        addSubview(descriptionLabel)
    }
    
    func setupConstraints() {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // container view
            containerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            
            // stack view
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // description label
            descriptionLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
        ])
    }
}

private extension CountersCreateView {
    @objc func didPressContinue() {
        print("here")
    }
}
