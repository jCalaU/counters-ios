//
//  String+Localizable.swift
//  Counters
//
//  Created by Javier Cala Uribe on 21/5/21.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
