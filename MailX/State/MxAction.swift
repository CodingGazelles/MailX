//
//  MxActions.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



protocol MxAction: ReSwift.Action, Loggable {}
typealias MxActionCreator = (state: MxAppState) -> MxAction
