//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderSO: MxStateObjectProtocol {
    
    var id: MxObjectId
    var code: String
    var name: String
    
    init( id: MxObjectId, code: String, name: String){
        self.id = id
        self.code = code
        self.name = name
    }
    
}

extension MxProviderSO: MxInitWithModel {
    init( model: MxProviderModel){
        self.init( id: model.id, code: model.code, name: model.name)
    }
}





