//
//  CountersListView.swift
//  Counters
//
//

import UIKit

protocol CounterListViewDelegate {
    func enableCellOptions(_ enable: Bool)
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
    
    var countersdb: [CounterCellPresenter] = []
    var filteredCounters: [CounterCellPresenter] = []
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
                
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
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
        //tableView.tableHeaderView = searchController.searchBar
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
        filteredCounters = countersdb.filter({( c : CounterCellPresenter ) -> Bool in
            let countersTitle = "\(c.countersdb.title!)"
          return countersTitle.lowercased().contains(searchText.lowercased())
        })

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

    // MARK: - DZNEmptyDataSet

extension CountersListView: DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var attributes = [NSAttributedString.Key : Any]()
        
        attributes[.foregroundColor] = UIColor.primaryText
        attributes[.font] = UIFontMetrics(forTextStyle: .headline).scaledFont(for: Font.title)
        attributes[.kern] = Font.kern

        let text = (currentState == .error) ? "COUNTERLIST_ERROR_TITLE".localized : "COUNTERLIST_EMPTY_TITLE".localized
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var attributes = [NSAttributedString.Key : Any]()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        attributes[.foregroundColor] = UIColor.secondaryText
        attributes[.font] = UIFontMetrics(forTextStyle: .body).scaledFont(for: Font.subtitle)
        attributes[.kern] = Font.kern
        attributes[.paragraphStyle] = paragraph
        
        let text = (currentState == .error) ? "COUNTERLIST_ERROR_SUBTITLE".localized : "COUNTERLIST_EMPTY_SUBTITLE".localized
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
//    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//        return UIImage.badge(sytemIcon: "42.circle.fill", color: .redCsm)
//    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = Font.button
        attributes[.foregroundColor] = UIColor.white
        attributes[.kern] = Font.kern
        
        let text = (currentState == .error) ? "COUNTERLIST_ERROR_BUTTON".localized : "COUNTERLIST_EMPTY_BUTTON".localized
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
        let sizeBtn : CGFloat = (currentState == .error) ? -120 : -80
        
        let capInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        let rectInsets = UIEdgeInsets(top: -20, left: sizeBtn, bottom: -20, right: sizeBtn)
        
        if let image = UIImage.badge(sytemIcon: "", color: .accentColor) {
            return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch).withAlignmentRectInsets(rectInsets)
        }
        return nil
    }
}

extension CountersListView: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if (self.currentState == .loading) || (isFiltering) {
            return false
        }
        return true
    }
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        //self.addCounter()
    }
}
