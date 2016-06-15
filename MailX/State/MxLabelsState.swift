//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes



// MARK: - State Object

struct MxLabelSO: MxStateObjectProtocol, MxCoreLabelProtocol {
    
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
    var code: String?
    var name: String?
    var ownerType: MxLabelOwnerType = MxLabelOwnerType.UNDEFINED
    
}

//extension MxLabelSO: MxInitWithModel {
//    init( model: MxLabel){
//        self.init(
//            internalId: model.internalId,
//            remoteId: model.remoteId,
//            code: model.code,
//            name: model.name,
//            ownerType: model.ownerType)
//    }
//}







