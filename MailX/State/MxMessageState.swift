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
    
}

//extension MxMessageSO: MxInitWithModel {
//    init( model: MxMessage){
//        self.init(
//            internalId: model.internalId,
//            remoteId: model.remoteId)
//    }
//}



//extension MxMessageSO: MxMessageRow {}
//
//protocol MxMessageRow: MxStateObjectProtocol {
//    var id: String { get set }
//}

