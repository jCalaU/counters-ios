//
//  CountersListEmptyView.swift
//  Counters
//
//  Created by Javier Cala Uribe on 28/5/21.
//

import Foundation
import UIKit

internal final class CountersListEmptyView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let title: String
        let description: String
        let buttonTitle: String
    }
    
    // MARK: - Properties

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let button = Button()
    private var buttonAction : (() -> Void)?

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
        titleLabel.attributedText = .init(string: viewModel.title,
                                          attributes: [.kern: Font.kern])
        subtitleLabel.attributedText = .init(string: viewModel.description,
                                                attributes: [.kern: Font.kern])
        button.setTitle(viewModel.buttonTitle, for: .normal)
    }
    
    func updateTexts(_ title: String, _ subtitle: String, _ buttonTxt: String, _ btnAction: @escaping (() -> Void)) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        button.setTitle(buttonTxt, for: .normal)
        buttonAction = btnAction
    }
    
    func hideButton(_ hide: Bool) {
        button.isHidden = hide
    }
}

// MARK: - Private Constants

private extension CountersListEmptyView {
    enum Constants {
        static let spacing: CGFloat = 20
        static let buttonHeight: CGFloat = 35
        static let stackViewTopMargin: CGFloat = 45
    }
    
    enum Font {
        static let kern: CGFloat = 0.34
        static let title = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let description = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    enum Shadow {
        static let opacity: Float = 1
        static let radius: CGFloat = 16
        static let offset = CGSize(width: 0, height: 8)
        static let color = UIColor(white: 0, alpha: 0.1).cgColor
    }
}

// MARK: - Private Implementation

private extension CountersListEmptyView {
    func setup() {
        backgroundColor = .background

        setupTitleLabel()
        setupSubtitleLabel()
        setupButton()
        setupViewHierarchy()
        setupConstraints()
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: Font.title)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        if #available(iOS 14.0, *) {
            /// used to leave the `Counters` as an Orphaned Word
            titleLabel.lineBreakStrategy = .hangulWordPriority
        }
    }
    
    func setupSubtitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: Font.description)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryText
    }
        
    func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        
        button.clipsToBounds = false
        button.layer.shadowRadius = Shadow.radius
        button.layer.shadowColor = Shadow.color
        button.layer.shadowOffset = Shadow.offset
        button.layer.shadowOpacity = Shadow.opacity
    }
    
    func setupViewHierarchy() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(button)
    }
    
    func setupConstraints() {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // subtitle label
            subtitleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.spacing),
            subtitleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.spacing),
            subtitleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            subtitleLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            // title label
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -Constants.spacing),
            
            // button
            button.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.buttonHeight
            ),
            button.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: Constants.spacing
            ),
            button.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
        ])
    }
}

private extension CountersListEmptyView {
    @objc func didPressButton() {
        self.buttonAction?()
    }
}
