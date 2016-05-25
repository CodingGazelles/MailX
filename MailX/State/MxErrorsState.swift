//
//  MxErrorState.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxErrorSO: MxStateObjectType, ErrorType {
    
    var UID: MxUID
    var message: String
    
    init(UID: MxUID?, message: String){
        self.init(UID: UID)
        self.message = message
    }
    
    init( error: MxException){
        self.init( UID: nil, message: error.description)
    }
}

extension MxErrorSO {
    init( error: MxModelError){
        self.init(UID: nil, message: error.description)
    }
}

func errorSO( error error: MxModelError) -> MxErrorSO {
    return MxErrorSO(error: error)
}


struct MxErrorsState: MxStateType {
    var errors = [MxErrorSO]()
}