//
//  MxUIStateModel.swift
//  MailX
//
//  Created by Tancrède on 6/4/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - State objects

protocol MxStateObjectProtocol: MxBusinessObjectProtocol {}

protocol MxInitWithModel {
    associatedtype Model: MxModelObjectProtocol
    init(model: Model)
}