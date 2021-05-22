//
//  WelcomeViewPresenter.swift
//  Counters
//
//

import UIKit

internal final class WelcomeViewPresenter {
    private let features: [WelcomeFeatureView.ViewModel] = [
        .init(
            badge: UIImage.badge(sytemIcon: "42.circle.fill",
                          color: UIColor(named: "Red")),
            title:"WELCOME_ADD_FEATURE_TITLE".localized,
            subtitle: "WELCOME_ADD_FEATURE_DESCRIPTION".localized
        ),
        .init(
            badge: UIImage.badge(sytemIcon: "person.2.fill",
                          color: UIColor(named: "Yellow")),
            title: "WELCOME_COUNT_SHARE_FEATURE_TITLE".localized,
            subtitle: "WELCOME_COUNT_SHARE_FEATURE_DESCRIPTION".localized
        ),
        .init(
            badge: UIImage.badge(sytemIcon: "lightbulb.fill",
                          color: UIColor(named: "Green")),
            title: "WELCOME_COUNT_FEATURE_TITLE".localized,
            subtitle: "WELCOME_COUNT_FEATURE_DESCRIPTION".localized
        )]
}

extension WelcomeViewPresenter: WelcomeViewControllerPresenter {
    var viewModel: WelcomeView.ViewModel {
        
        let welcome = NSMutableAttributedString(string: "WELCOME_TITLE".localized)
        let range = (welcome.string as NSString).range(of: "APP_NAME".localized)
        if let color = UIColor(named: "AccentColor"), range.location != NSNotFound {
            welcome.setAttributes([.foregroundColor: color], range: range)
        }
        
        return .init(title: welcome,
                     description: "WELCOME_DESCRIPTION".localized,
                     features: features,
                     buttonTitle: "WELCOME_PRIMARY_ACTION_TITLE".localized)
    }
}
