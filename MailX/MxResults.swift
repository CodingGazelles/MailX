//
//  MxErrorsManager.swift
//  Hexmail
//
//  Created by Tancrède on 5/11/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import Result


// MARK: - MxReturn

extension Result where Error: MxError {
    
    func unwrap() -> Value? {
        switch self {
        case let .Success(value):
            return value
        case let .Failure(error):
            error.logIt()
            return nil
        }
    }
}





