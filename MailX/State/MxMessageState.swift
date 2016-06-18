//
//  MxMessageState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMessageSO: MxStateObjectProtocol, MxMessageProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    
    init(){}
    
    init( internalId: MxInternalId, remoteId: MxRemoteId){
        self.internalId = internalId
        self.remoteId = remoteId
    }
    
    init( model: MxMessage){
        self.internalId = model.internalId
        self.remoteId = model.remoteId
    }
    
}



