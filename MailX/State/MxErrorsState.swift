//
//  MxErrorState.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxErrorSO {
    
    var message: String = ""
    
    init( error: MxExceptionProtocol){
        self.message = error.description
    }
}


