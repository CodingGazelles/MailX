//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderSO: MxStateObjectType {
    
    var UID: MxUID
    var id: String
    var name: String
    
    init(UID: MxUID?, id: String, name: String){
        self.init(UID: UID)
        self.id = id
        self.name = name
    }
    
    init(providerSO: MxProviderSO){
        self.init(UID: providerSO.UID, id: providerSO.id, name: providerSO.name)
    }
}

struct MxProvidersState: MxStateType {
    var providers = [MxProviderSO]()
}



