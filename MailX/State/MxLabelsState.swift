//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - State Object

struct MxLabelSO: MxStateObjectProtocol, MxLabelProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var code: MxLabelCode = MxLabelCode.USER("NA")
    var name: String?
    var ownerType: MxLabelOwnerType = MxLabelOwnerType.UNDEFINED
    
    init(){}
    
    init( internalId: MxInternalId?, remoteId: MxRemoteId?, code: MxLabelCode, name: String?, ownerType: MxLabelOwnerType){
        self.internalId = internalId
        self.remoteId = remoteId
        self.code = code
        self.name = name
        self.ownerType = ownerType
    }
    
    init( model: MxLabel){
        self.internalId = model.internalId
        self.remoteId = model.remoteId
        self.code = model.code
        self.name = model.name
        self.ownerType = model.ownerType
    }
    
}









