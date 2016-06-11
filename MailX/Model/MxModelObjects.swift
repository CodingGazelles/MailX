//
//  MxModelObjects.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation

import Result



// MARK: - Root model object

protocol MxModelObjectProtocol: MxBusinessObjectProtocol {
    
    var internalId: String { get set }
    var remoteId: String { get set }
    
    init()
}

extension MxModelObjectProtocol {
    
    var id: MxObjectId {
        get {
            return MxObjectId(internalId: MxInternalId(value: internalId), remoteId: MxRemoteId(value: remoteId))
        }
        set {
            self.internalId = newValue.internalId.value
            self.remoteId = newValue.remoteId.value
        }
    }
    
}




