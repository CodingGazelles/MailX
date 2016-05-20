//
//  MxActions.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



protocol MxAction: Action {}
typealias MxActionCreator = (state: MxAppState, store: MxStateStore) -> MxAction
