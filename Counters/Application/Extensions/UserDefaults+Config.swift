//
//  UserDefaults+Config.swift
//  Counters
//
//  Created by Javier Cala Uribe on 28/5/21.
//

import Foundation

extension UserDefaults {
    var welcomeSeen: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
