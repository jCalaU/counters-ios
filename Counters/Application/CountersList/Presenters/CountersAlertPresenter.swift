//
//  CountersAlertPresenter.swift
//  Counters
//
//  Created by Javier Cala Uribe on 28/5/21.
//

import UIKit

struct CountersAlertPresenter {
    let title: String?
    let message: String?
    let actionTitles: [String]
    let actions: [() -> Void]
    let viewController: UIViewController?
        
    static func error(
        title: String? = nil,
        message: String,
        actionTitles: [String] = [],
        actions: [() -> Void] = [],
        viewController: UIViewController? = nil
    ) -> CountersAlertPresenter {
        return CountersAlertPresenter(title: title, message: message, actionTitles: actionTitles, actions: actions, viewController: viewController)
    }
}
