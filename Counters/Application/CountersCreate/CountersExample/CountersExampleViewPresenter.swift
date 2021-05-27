//
//  CountersExampleViewPresenter.swift
//  Counters
//
//

import UIKit

internal final class CountersExampleViewPresenter {

}

extension CountersExampleViewPresenter: CountersExampleViewControllerPresenter {
    var viewModel: CountersExampleView.ViewModel {
                
        let description = NSMutableAttributedString(string: "COUNTERSEXAMPLE_SUBTITLE".localized, attributes:[.foregroundColor: UIColor.secondaryText as Any])
        
        return .init(description: description)
    }
}
