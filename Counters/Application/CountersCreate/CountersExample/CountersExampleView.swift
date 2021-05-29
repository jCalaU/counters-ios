//
//  CountersExampleView.swift
//  Counters
//
//

import UIKit

protocol CountersExampleViewDelegate {
    func selectedExampleTag(_ tag: String)
}

internal final class CountersExampleView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let description: NSAttributedString
    }
    
    // MARK: - Properties

    let tagsExamples = TagsExampleJSON.tagsExampleJSON()
    
    private let descriptionLabel = UILabel()
    private var tableView = UITableView()
    
    var delegate: CountersExampleViewDelegate?
    
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

private extension CountersExampleView {
    enum Constants {
        static let spacing: CGFloat = 24
        static let descriptionHeight: CGFloat = 50
    }
    
    enum Font {
        static let kern: CGFloat = 0.34
        static let description = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}

    // MARK: - Private Implementation

private extension CountersExampleView {
    func setup() {
        backgroundColor = .background

        setupDescriptionLabel()
        setupTableView()
        setupViewHierarchy()
        setupConstraints()
    }
    
    func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font.description)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        descriptionLabel.layer.masksToBounds = true
        descriptionLabel.layer.borderColor = UIColor.lightGray.cgColor
        descriptionLabel.layer.borderWidth = 0.5
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false

        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        tableView.register(TagTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
        
    func setupViewHierarchy() {
        addSubview(descriptionLabel)
        addSubview(tableView)
    }
    
    func setupConstraints() {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // container view
            descriptionLabel.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.descriptionHeight
            ),
            descriptionLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0),
            descriptionLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
            
            // collectionView
            tableView.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: Constants.spacing
            ),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }
}

// MARK: - UITableView Delegates

extension CountersExampleView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tagsExamples.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TagTableViewCell
        cell.collectionView.tag = indexPath.section
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tagsExamples[section].title_section
    }
}

extension CountersExampleView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12, weight: .regular))
        header.textLabel?.textColor = .subtitleText
        view.tintColor = .background
    }
}

extension CountersExampleView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsExamples[collectionView.tag].tags.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! TagCollectionViewCell
        cell.titleLabel.text  = tagsExamples[collectionView.tag].tags[indexPath.row]
        cell.backgroundColor = .backgroundCell
        cell.layer.cornerRadius = 9

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
        guard let text = cell.titleLabel.text else { return }
        delegate?.selectedExampleTag(text)
    }
}
