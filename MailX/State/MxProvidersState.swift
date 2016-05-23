//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderSO: MxStateObjectType {
    var UID: String
    var id: String
    var name: String
    
    init(id: String, name: String){
        self.init()
        self.id = id
        self.name = name
    }
    
    init(providerSO: MxProviderSO){
        self.init(dataObject: providerSO)
        self.init(id: providerSO.id, name: providerSO.name)
    }
}

struct MxProvidersState: MxStateType {
    var providers = [MxProviderSO]()
}



