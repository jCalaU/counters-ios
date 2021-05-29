//
//  CountersStatePresenter.swift
//  Counters
//
//  Created by Javier Cala Uribe on 28/5/21.
//

import UIKit

enum ViewState : String {
    case loading, empty, error, content
}

protocol CountersListState {
    func validState(_ state: ViewState)
    func setLoadingState()
    func setEmptyState()
    func setErrorState()
    func setContentState()
}

final class CountersStatePresenter {
    
    // MARK: - Properties

    var countersListViewController : CountersListViewController!
    var barPresenter : CountersBarPresenter!
    var countersListpresenter: CountersListViewControllerPresenter!
    
    // MARK: - Implementation
    
    func getCountersCellPresenter() -> [CountersCellPresenter] {
    
        var counterCellArray = [CountersCellPresenter]()
        let fetchedObjects = CNCoreData.sharedInstance.getCNCounters()
        for obj in fetchedObjects {
            let counterCell = CountersCellPresenter(obj)
            counterCell.delegate = self
            counterCellArray.append(counterCell)
        }
        
        return counterCellArray
    }
    
    func updateViewState() {
        if countersListViewController.innerView.isFiltering {
            countersListViewController.innerView.filterContentForSearchText(countersListViewController.innerView.searchController.searchBar.text!)
        }
        barPresenter.setBarBottomTitle(countersListViewController)
        countersListViewController.innerView.tableView.reloadData()
    }
}

// MARK: - CountersListState Implementation

extension CountersStatePresenter: CountersListState {
    
    func validState(_ state: ViewState) {
        countersListViewController.innerView.countersdb = self.getCountersCellPresenter()

        switch state {
        // Error
        case .error:
            if  countersListViewController.innerView.countersdb.count == 0 {
                setErrorState()
            } else {
                setContentState()
            }
        // Content
        case .content:
            if  countersListViewController.innerView.countersdb.count == 0 {
                setEmptyState()
            } else {
                setContentState()
            }

        default:
            Logger("o_O")
        }
    }
    
    func setLoadingState() {
        countersListViewController.innerView.currentState = .loading
        countersListViewController.innerView.activityIndicator.startAnimating()
        barPresenter.enableEditButton(false)
        countersListViewController.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
    }
    
    func setEmptyState() {
        countersListViewController.innerEmptyView.updateTexts("COUNTERLIST_EMPTY_TITLE".localized,
                                        "COUNTERLIST_EMPTY_SUBTITLE".localized,
                                        "COUNTERLIST_EMPTY_BUTTON".localized,
                                        self.barPresenter.addButtonPressed)
        countersListViewController.innerView.tableView.backgroundView = countersListViewController.innerEmptyView
        countersListViewController.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false

        countersListViewController.innerView.currentState = .empty
        countersListViewController.innerView.activityIndicator.stopAnimating()
        
        barPresenter.enableEditButton(false)
        
        self.updateViewState()
    }
    
    func setErrorState() {
        countersListViewController.innerEmptyView.updateTexts("COUNTERLIST_ERROR_TITLE".localized,
                                        "COUNTERLIST_ERROR_SUBTITLE".localized,
                                        "COUNTERLIST_ERROR_BUTTON".localized,
                                        countersListViewController.getAllCountersFromServer)
        countersListViewController.innerView.tableView.backgroundView = countersListViewController.innerEmptyView
        countersListViewController.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false

        countersListViewController.innerView.currentState = .error
        countersListViewController.innerView.activityIndicator.stopAnimating()

        barPresenter.enableEditButton(false)

        self.updateViewState()
    }
    
    func setContentState() {
        countersListViewController.innerView.currentState = .content
        countersListViewController.innerView.activityIndicator.stopAnimating()
        
        countersListViewController.innerView.tableView.backgroundView = nil
        countersListViewController.navigationItem.searchController?.searchBar.isUserInteractionEnabled = true

        barPresenter.enableEditButton(true)

        self.updateViewState()
    }
}

// MARK: - CountersCellPresenterDelegate
extension CountersStatePresenter : CountersCellPresenterDelegate {
    
    func reloadTableView() {
        self.validState(.content)
    }
    
    func showErrorMessage(_ title:String, _ error:Error?, _ retryAction: @escaping (() -> Void)) {
        var alertMessage = "Error".localized
        if let err = error {
            alertMessage = err.localizedDescription
        }
        
        let retryTitle = "COUNTERSALERTPRESENTER_RETRY".localized
        let dismissTitle = "COUNTERSALERTPRESENTER_DISMISS".localized
        countersListpresenter.display(.error(
                            title: title,
                            message: alertMessage,
                            actionTitles: [retryTitle, dismissTitle],
                            actions: [retryAction],
                            viewController: countersListViewController
        ))
    }
}
