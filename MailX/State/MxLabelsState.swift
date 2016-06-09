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
    var mailboxId: MxObjectId
    
    init?( id: MxObjectId, code: String, name: String, ownerType: String, mailboxId: MxObjectId){
        
        guard MxLabelOwnerType(rawValue: ownerType) != nil else {
            return nil
        }
        
        self.id = id
        self.code = code
        self.name = name
        self.ownerType = ownerType
        self.mailboxId = mailboxId
    }
    
}

extension MxLabelSO: MxInitWithModel {
    init( model: MxLabelModel){
        self.init(
            id: model.id
            , code: model.code
            , name: model.name
            , ownerType: model.ownerType.rawValue
            , mailboxId: model.mailboxId)!
    }
}

//func toSO( label label: Result<MxLabelModel,MxStackError>) -> Result<MxLabelSO, MxSOError> {
//    switch label {
//    case let .Success(model):
//        return Result.Success( MxLabelSO(model: model))
//    case let .Failure( error):
//        return Result.Failure( errorSO(error: error))
//    }
//}




//MARK: Extensions

//extension MxLabelSO: MxLabelRow {}
//
//protocol MxLabelRow: MxStateObjectProtocol {
//    var code: String { get set }
//    var name: String { get set }
//}





