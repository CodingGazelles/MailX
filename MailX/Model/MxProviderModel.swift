//
//  MxProviderModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



typealias MxProviderModelResult = Result<MxProviderModel, MxDBError>

struct MxProviderModel: MxModelType {
    
    var UID: MxUID
    var id: MxProviderModelId
    
    init(UID: MxUID?, id: MxProviderModelId){
        
        self.UID = UID ?? MxUID()
        self.id = id
        
    }
}

struct MxProviderModelId: MxModelIdType {
    var value: String
}

extension MxProviderModel: MxInitWithDBO {
    init( dbo: MxProviderDBO){
        
        self.init(
            UID: dbo.UID
            , id: MxProviderModelId( value: dbo.id))
    }
}
