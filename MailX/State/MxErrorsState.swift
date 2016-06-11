//
//  MxErrorState.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxErrorSO: MxStateObjectProtocol, MxExceptionProtocol {
    
    var id: MxObjectId
    var message: String
    
    init(id: MxObjectId, message: String){
        self.id = id
        self.message = message
    }
    
    init( error: MxExceptionProtocol){
        self.init( id: MxObjectId(), message: error.description)
    }
}

extension MxErrorSO {
    init( error: MxStackError){
        self.init(id: MxObjectId(), message: error.description)
    }
}

func errorSO( error error: MxStackError) -> MxErrorSO {
    return MxErrorSO(error: error)
}


