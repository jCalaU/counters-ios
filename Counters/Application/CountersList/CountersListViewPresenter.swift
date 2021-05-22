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
        
        let title = NSMutableAttributedString(string: NSLocalizedString("APP_NAME", comment: ""))
        
        return .init(title: title,
                     description: NSLocalizedString("WELCOME_DESCRIPTION", comment: ""))
    }
}
