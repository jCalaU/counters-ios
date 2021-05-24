//
//  CountersCreateViewPresenter.swift
//  Counters
//
//

import UIKit

internal final class CountersCreateViewPresenter {

}

extension CountersCreateViewPresenter: CountersCreateViewControllerPresenter {
    var viewModel: CountersCreateView.ViewModel {
        
        let title = NSMutableAttributedString(string: "APP_NAME".localized)
        
        return .init(title: title,
                     description: "WELCOME_DESCRIPTION".localized)
    }
}
