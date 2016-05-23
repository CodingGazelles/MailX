//
//  MxMessageState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMessageSO: MxStateObjectType {
    
    var UID: String
    var id: String
    
    init(id: String){
        self.init()
        self.id = id
    }
    
    init(messageSO: MxMessageSO){
        self.init(dataObject: messageSO)
        self.init(id: messageSO.id)
    }
}

struct MxMessageState: MxStateType {
    var messages = [MxMessageRow]()
}


extension MxMessageSO: MxMessageRow {}

protocol MxMessageRow: MxStateObjectType {
    var id: String { get set }
}

