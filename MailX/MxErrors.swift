//
//  Errors.swift
//  Hexmail
//
//  Created by Tancrède on 5/13/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation






// MARK: - MxError

protocol LoggableError {
    func logIt()
}

extension LoggableError {
    func logIt() {
        MxLog.error("Error: \(self)")
    }
}

protocol MxError: ErrorType, LoggableError {}