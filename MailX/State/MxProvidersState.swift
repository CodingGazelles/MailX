//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderSO: MxStateObjectProtocol, MxManagedObject, MxProviderProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var code: String?
    var name: String?
    
    init(){}
    
    init( internalId: MxInternalId, remoteId: MxRemoteId, code: String?, name: String?){
        self.internalId = internalId
        self.remoteId = remoteId
        self.code = code
        self.name = name
    }
    
    init( model: MxProvider){
        self.internalId = model.internalId
        self.remoteId = model.remoteId
        self.code = model.code
        self.name = model.name
    }
}






