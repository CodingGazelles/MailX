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


struct MxMailboxModel : MxModel {
    
    var id: MxModelId
    var providerId: MxModelId
    
    init(id: MxModelId, providerId: MxModelId){
        self.id = id
        self.providerId = providerId
    }
}

