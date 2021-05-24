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
                
        let description = NSMutableAttributedString(string: "COUNTERSCREATE_DESCRIPTION".localized, attributes:[.foregroundColor: UIColor.secondaryText as Any])
        let range = (description.string as NSString).range(of: "COUNTERSCREATE_EXAMPLES".localized)
        if range.location != NSNotFound {
            description.addAttribute(.underlineStyle, value: 1, range: range)
        }
        
        return .init(description: description)
    }
}
