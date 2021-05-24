//
//  CountersListViewPresenter.swift
//  Counters
//
//

import UIKit

internal final class CountersListViewPresenter {

}

extension CountersListViewPresenter: CountersListViewControllerPresenter {
    var viewModel: CountersListView.ViewModel {
        
        let title = NSMutableAttributedString(string: "APP_NAME".localized)
        
        return .init(title: title,
                     description: "WELCOME_DESCRIPTION".localized)
    }
}
