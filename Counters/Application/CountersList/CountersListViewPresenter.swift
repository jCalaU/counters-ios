//
//  CountersListViewPresenter.swift
//  Counters
//
//

import UIKit

enum ViewState : String {
    case loading, empty, error, content
}

protocol CountersListState {    
    func setLoadingState()
    func setEmptyState()
    func setErrorState()
    func setContentState()
}

internal final class CountersListViewPresenter {
}

extension CountersListViewPresenter: CountersListViewControllerPresenter {
    
    var viewModel: CountersListView.ViewModel {
        
        let title = NSMutableAttributedString(string: "APP_NAME".localized)
        
        return .init(title: title,
                     description: "WELCOME_DESCRIPTION".localized)
    }
    
    var viewEmptyModel: CountersListEmptyView.ViewModel  {
                
        return .init(title: "COUNTERLIST_EMPTY_TITLE".localized,
                     description: "COUNTERLIST_EMPTY_SUBTITLE".localized,
                     buttonTitle: "COUNTERLIST_EMPTY_BUTTON".localized)
    }
    
    func display(_ view: CounterAlertPresenter) {
        
        guard let viewController = view.viewController else { return }
        
        let alertController = UIAlertController(title: view.title, message: view.message, preferredStyle: .alert)
        let actionRetry = UIAlertAction(title: view.actionTitles[0], style: .cancel) { _ in
            guard !view.actions.isEmpty else {return}
            view.actions[0]()
        }
        if view.actionTitles.count > 1 {
            let actionDismiss = UIAlertAction(title: view.actionTitles[1], style: .default, handler: nil)
            alertController.addAction(actionDismiss)
        }
        alertController.addAction(actionRetry)
        
        viewController.present(alertController, animated: true)
    }
}
