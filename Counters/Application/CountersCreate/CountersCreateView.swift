//
//  CountersCreateView.swift
//  Counters
//
//

import UIKit

internal final class CountersCreateView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let title: NSAttributedString
        let description: String
    }
    
    // MARK: - Properties

    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    
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
        static let title = UIFont.systemFont(ofSize: 33, weight: .heavy)
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

private extension CountersCreateView {
    func setup() {
        backgroundColor = .systemBackground

        setupTableView()
        setupViewHierarchy()
        setupConstraints()
    }
        
    func setupTableView() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        tableView.register(CounterCell.self, forCellReuseIdentifier: "Cell")
    }
        
    func setupViewHierarchy() {
        addSubview(tableView)
        tableView.tableHeaderView = searchController.searchBar
        tableView.addSubview(searchController.searchBar)
    }
    
    func setupConstraints() {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // tableview
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}

private extension CountersCreateView {
    @objc func didPressContinue() {
        print("here")
    }
}
