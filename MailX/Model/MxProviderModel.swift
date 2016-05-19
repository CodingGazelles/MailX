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


struct MxProviderModel: MxModel {
    
    var id: MxModelId
    
    init(id: MxModelId){
        self.id = id
    }
}

