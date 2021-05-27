//
//  TagCollectionCell.swift
//  Counters
//
//  Created by Javier Cala Uribe on 27/5/21.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    var titleLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    // MARK: - Private definitions
    
private extension TagCollectionViewCell {

    enum LayoutConstants {
        static let cornerRadius: CGFloat = 8.0
        static let titleHeight: CGFloat = 50.0
        static let anchor: CGFloat = 20.0
    }
    
    enum Font {
        static let kern: CGFloat = 0.51
        static let title = UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    func setup() {
        setupTitleLable()
        setupHierarchy()
        setupConstraints()
    }
    
    func setupTitleLable(){
        titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: Font.title)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = LayoutConstants.cornerRadius
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .white
    }
    
    func setupHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // title label
            titleLabel.heightAnchor.constraint(
                greaterThanOrEqualToConstant: LayoutConstants.titleHeight
            ),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:LayoutConstants.anchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:-LayoutConstants.anchor),
        ])
    }
}
