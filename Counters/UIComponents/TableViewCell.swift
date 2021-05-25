//
//  CounterCell.swift
//  Counters
//
//

import UIKit

final class CounterCell: UITableViewCell {
    private let containerView = UIView()
    private let separatorView = UIView()
    let titleLabel = UILabel()
    let countLabel = UILabel()
    let stepper = UIStepper()
    
    private var previusStepperValue = 0.0
    
    var onIncrease: (() -> Void)?
    var onDecrease: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStepperValue(_ value: Double) {
        stepper.value = value
        previusStepperValue = value
    }
    
    @objc private func stepperValueChanged(_ stepper: UIStepper) {
        if stepper.value > previusStepperValue {
            onIncrease?()
        } else if stepper.value < previusStepperValue {
            onDecrease?()
        }
    }
}

private extension CounterCell {
    func setup() {
        multipleSelectionBackgroundView = UIView()
        multipleSelectionBackgroundView?.backgroundColor = .clear
        backgroundColor = .clear
        
        setupContainerView()
        setupSeparatorView()
        setupTitleLabel()
        setupCountLabel()
        setupStepper()
        setupViewHierarchy()
        setupConstraints()
    }
    
    func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
    }
    
    func setupSeparatorView() {
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        separatorView.backgroundColor = .background
    }
    
    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = .primaryText
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.adjustsFontForContentSizeCategory = true
        
    }
    
    func setupCountLabel() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.textColor = .accentColor
        countLabel.textAlignment = .right
        countLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        countLabel.adjustsFontForContentSizeCategory = true
    }
    
    func setupStepper() {
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        stepper.autorepeat = false
        stepper.isContinuous = false
        stepper.wraps = false
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
    }
    
    func setupViewHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(countLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stepper)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // container view
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            // separator view
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 60),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            // title label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            titleLabel.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: 10),

            // count label
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            countLabel.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: -10),
            countLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            countLabel.bottomAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor, constant: 5),
            
            // stepper
            stepper.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            stepper.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        ])
    }
}
