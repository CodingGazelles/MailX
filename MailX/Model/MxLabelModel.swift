//
//  LabelModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



typealias MxLabelModelArray = [MxLabelModel]
typealias MxLabelModelOptArray = [MxLabelModel?]

struct MxLabelModel: MxModelType {
    
    enum MxLabelOwnerType: String {
        case SYSTEM = "SYSTEM"
        case USER = "USER"
        case UNKNOWN
    }
    
    var UID: String
    var id: MxLabelModelId
    var code: String
    var name: String
    var ownerType: MxLabelOwnerType
    var mailboxId: MxMailboxModelId
    
    init(id: MxLabelModelId, code: String, name: String, ownerType: MxLabelOwnerType, mailboxId: MxMailboxModelId){
        self.init()
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

extension MxLabelModel {
    init?( labelDBO: MxLabelDBO){
        
        guard let ownerType = MxLabelOwnerType( rawValue: labelDBO.ownerType) else {
            return nil
        }
        
        let id = MxLabelModelId( value: labelDBO.id)
        let mailboxId = MxMailboxModelId( value: labelDBO.mailbox!.id)
        
        self.init(dataObject: labelDBO)
        self.init(
            id: id
            , code: labelDBO.code
            , name: labelDBO.name
            , ownerType: ownerType
            , mailboxId: mailboxId)
    }
}