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

final class MxProviderModel: MxModelType, MxLocalPersistable {
    
    var UID: MxUID
    var code: String
    
    init(UID: MxUID?, code: String){
        self.UID = UID ?? MxUID()
        self.code = code
    }
    
    convenience init( dbo: MxProviderDBO){
        self.init(
            UID: dbo.UID
            , code: dbo.code)
    }
}

final class MxProviderModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}

