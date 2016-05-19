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


struct MxLabelModel: MxModel {
    
    enum MxLabelOwnerType: String {
        case SYSTEM = "SYSTEM"
        case USER = "USER"
    }
    
    var id: MxModelId
    var name: String
    var type: MxLabelOwnerType
    var mailboxId: MxModelId
    
    init(id: MxModelId, name: String, type: MxLabelOwnerType, mailboxId: MxModelId){
        self.id = id
        self.name = name
        self.type = type
        self.mailboxId = mailboxId
    }
}
