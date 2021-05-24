//
//  CountersListView.swift
//  Counters
//
//

import UIKit

internal final class CountersListView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let title: NSAttributedString
        let description: String
    }
    
    // MARK: - Properties

    private let refreshControl = UIRefreshControl()
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

private extension CountersListView {
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

private extension CountersListView {
    func setup() {
        backgroundColor = .systemBackground

        setupTableView()
        setupSearchController()
        setupViewHierarchy()
        setupConstraints()
    }
        
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refreshCountersData(_:)), for: .valueChanged)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        tableView.register(CounterCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "COUNTERSLIST_SEARCH".localized
        searchController.searchBar.delegate = self
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

private extension CountersListView {
    @objc private func refreshCountersData(_ sender: Any) {
        print("here")
    }
}

    // MARK: - UITableView Delegates

extension CountersListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CounterCell
        return cell
    }
}

extension CountersListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

    // MARK: - UISearchController Delegates

extension CountersListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension CountersListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //filterContentForSearchText(searchController.searchBar.text!)
    }
}
