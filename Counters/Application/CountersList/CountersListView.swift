//
//  CountersListView.swift
//  Counters
//
//

import UIKit

protocol CounterListViewDelegate {
    func enableCellOptions(_ enable: Bool)
    func setFilteringState(_ enable: Bool)
}

internal final class CountersListView: UIView {
    // MARK: - View Model

    struct ViewModel {
        let title: NSAttributedString
        let description: String
    }
    
    // MARK: - Properties
    
    var tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    var currentState : ViewState = .loading
    let activityIndicator = UIActivityIndicatorView()
    
    var countersdb: [CountersCellPresenter] = []
    var filteredCounters: [CountersCellPresenter] = []
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
      return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    var delegate: CounterListViewDelegate?
    
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
        static let title = UIFont.systemFont(ofSize: 19, weight: .semibold)
        static let subtitle = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let description = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let button = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
}

    // MARK: - Private Implementation

private extension CountersListView {
    func setup() {
        backgroundColor = .systemBackground

        setupTableView()
        setupSearchController()
        setupActivityIndicator()
        setupViewHierarchy()
        setupConstraints()
    }
            
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.allowsMultipleSelectionDuringEditing = true

        tableView.backgroundColor = .background
        tableView.tableFooterView = UIView()
        tableView.register(CounterTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "COUNTERSLIST_SEARCH".localized
        searchController.searchBar.delegate = self
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
    }
    
    func setupViewHierarchy() {
        addSubview(tableView)
        addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        let guide = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // tableview
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            // activityIndicator
            activityIndicator.topAnchor.constraint(equalTo: guide.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}

extension CountersListView {
    
    func filterContentForSearchText(_ searchText: String) {
        filteredCounters = countersdb.filter({( c : CountersCellPresenter ) -> Bool in
            let countersTitle = "\(c.countersdb.title!)"
          return countersTitle.lowercased().contains(searchText.lowercased())
        })
        
        if (filteredCounters.count == 0) && isFiltering {
            self.delegate?.setFilteringState(true)
        } else {
            self.delegate?.setFilteringState(false)
        }
        
        tableView.reloadData()
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
        return isFiltering ? filteredCounters.count : countersdb.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CounterTableViewCell
        
        let cnCounter : CNCounters = isFiltering ? filteredCounters[indexPath.row].countersdb : countersdb[indexPath.row].countersdb
        
        cell.counterId = cnCounter.id
        cell.titleLabel.text = cnCounter.title
        cell.countLabel.text = "\(cnCounter.count)"
        cell.countLabel.textColor = cnCounter.count > 0 ? .accentColor : .disabledText
        cell.setStepperValue(Double(cnCounter.count))
        cell.onIncrease = isFiltering ? filteredCounters[indexPath.row].requestCounterIncrease : countersdb[indexPath.row].requestCounterIncrease
        cell.onDecrease = isFiltering ? filteredCounters[indexPath.row].requestCounterDecrease : countersdb[indexPath.row].requestCounterDecrease
        
        return cell
    }    
}

extension CountersListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let enable = (tableView.indexPathsForSelectedRows != nil) ? true : false
        self.delegate?.enableCellOptions(enable)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let enable = (tableView.indexPathsForSelectedRows != nil) ? true : false
        self.delegate?.enableCellOptions(enable)
    }
}

    // MARK: - UISearchController Delegates

extension CountersListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension CountersListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
