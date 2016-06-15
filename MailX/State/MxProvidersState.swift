//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderSO: MxStateObjectProtocol, MxManagedObject, MxCoreProviderProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var code: String?
    var name: String?
    
}

//extension MxProviderSO: MxInitWithModel {
//    init( model: MxProvider){
//        self.init( internalId: model.internalId,
//                   remoteId: model.remoteId,
//                   code: model.code,
//                   name: model.name)
//    }
//}





