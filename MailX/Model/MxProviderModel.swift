//
//  MxProviderModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



typealias MxProviderModelArray = [MxProviderModel]
typealias MxProviderModelOptArray = [MxProviderModel?]

struct MxProviderModel: MxModelType {
    var UID: String
    var id: MxProviderModelId
    
    init(id: MxProviderModelId){
        self.init()
        self.id = id
    }
}

struct MxProviderModelId: MxModelIdType {
    var value: String
}

