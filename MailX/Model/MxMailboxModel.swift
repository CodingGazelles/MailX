//
//  MxMailboxModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



typealias MxMailboxModelArray = [MxMailboxModel]
typealias MxMailboxModelOptArray = [MxMailboxModel?]

struct MxMailboxModel: MxModelType {
    
    var UID: String
    var id: MxMailboxModelId
    var name: String
    var connected: Bool
    var providerId: MxProviderModelId
    
    init(id: MxMailboxModelId, name: String, connected: Bool, providerId: MxProviderModelId){
        self.init()
        self.id = id
        self.name = name
        self.connected = connected
        self.providerId = providerId
    }
}

struct MxMailboxModelId: MxModelIdType{
    var value: String
}

extension MxMailboxModel {
    init( mailboxDBO: MxMailboxDBO){
        self.init(dataObject: mailboxDBO)
        self.init(
            id: MxMailboxModelId( value: mailboxDBO.id)
            , name: mailboxDBO.name
            , connected: false
            , providerId: MxProviderModelId( value: mailboxDBO.provider!.id))
    }
}

