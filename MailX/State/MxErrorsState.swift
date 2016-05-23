//
//  MxErrorState.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxErrorSO: MxStateObjectType {
    var UID: String
    var message = ""
    
    init(message: String){
        self.init()
        self.message = message
    }
}

extension MxErrorSO {
    init( error: MxError){
        self.message = error.description
    }
}

struct MxErrorsState: MxStateType {
    var errors = [MxErrorSO]()
}