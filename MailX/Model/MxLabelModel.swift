//
//  LabelModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



typealias MxLabelModelResult = Result<MxLabelModel, MxModelError>

struct MxLabelModel: MxModelType {
    
    var UID: MxUID
    var id: MxLabelModelId
    var code: String
    var name: String
    var ownerType: MxLabelOwnerType
    var mailboxId: MxMailboxModelId
    
    init(UID: MxUID?
        , id: MxLabelModelId
        , code: String
        , name: String
        , ownerType: MxLabelOwnerType
        , mailboxId: MxMailboxModelId){
        
        self.init(UID: UID)
        self.id = id
        self.code = code
        self.name = name
        self.ownerType = ownerType
        self.mailboxId = mailboxId
    }
}

struct MxLabelModelId: MxModelIdType{
    var value: String
}

extension MxLabelModel: MxInitWithDBO {
    init?( dbo: MxLabelDBO){
        
        guard let ownerType = MxLabelOwnerType( rawValue: dbo.ownerType) else {
            return nil
        }
        
        let id = MxLabelModelId( value: dbo.id)
        let mailboxId = MxMailboxModelId( value: dbo.mailbox!.id)
        
        self.init(
            UID: dbo.UID
            , id: id
            , code: dbo.code
            , name: dbo.name
            , ownerType: ownerType
            , mailboxId: mailboxId)
    }
}

func toModel( dbo dbo: MxLabelDBO) -> MxLabelModelResult {
    
    guard MxLabelOwnerType( rawValue: dbo.ownerType) != nil else {
        
        let error =  MxModelError.UnableToConvertDBOToModel(
            dbo: dbo
            , message: "Unable to instanciate MxLabelOwnerType with args: \(dbo.ownerType)"
            , rootError: nil)
        
        return Result.Failure( error)
    }
    
    return Result.Success( MxLabelModel(dbo: dbo)!)
}
