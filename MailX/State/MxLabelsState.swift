//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes



// MARK: - State Object

struct MxLabelSO: MxStateObjectProtocol {
    
    var id: MxObjectId
    var code: String
    var name: String
    var ownerType: String
    
    init?( id: MxObjectId, code: String, name: String, ownerType: String){
        
        guard MxLabelOwnerType(rawValue: ownerType) != nil else {
            return nil
        }
        
        self.id = id
        self.code = code
        self.name = name
        self.ownerType = ownerType
    }
    
}

extension MxLabelSO: MxInitWithModel {
    init( model: MxLabelModel){
        self.init(
            id: model.id
            , code: model.code
            , name: model.name
            , ownerType: model.ownerType)!
    }
}







