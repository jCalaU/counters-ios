//
//  Constants.swift
//  Counters
//
//  Created by Javier Cala Uribe on 21/5/21.
//

import Foundation

public func Logger(_ message:String) {
    #if DEBUG
    print(message)
    #endif
}
