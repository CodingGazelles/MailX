//
//  MxMailboxProtocol.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



// MARK: - State Object

typealias MxMailboxSOResult = Result<MxMailboxSO, MxSOError>

struct MxMailboxSO: MxStateObjectProtocol {
    
    var id: MxObjectId
    var email: String
    var name: String
    var connected: Bool
    var providerCode: String
    
    init( id: MxObjectId, email: String, name: String, connected: Bool, providerCode: String){
        self.id = id
        self.email = email
        self.name = name
        self.connected = connected
        self.providerCode = providerCode
    }
    
}

extension MxMailboxSO: MxInitWithModel {
    init( model: MxMailboxModel){
        self.init(
            id: model.id
            , email: model.email
            , name: model.name
            , connected: model.connected
            , providerCode: model.providerCode)
    }
}

//func toSO( mailbox mailbox: Result<MxMailboxModel, MxStackError> ) -> MxMailboxSOResult {
//    switch mailbox {
//    case let .Success(model):
//        return Result.Success( MxMailboxSO(model: model))
//    case let .Failure( error):
//        return Result.Failure( errorSO(error: error))
//    }
//}
//







