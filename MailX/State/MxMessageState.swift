//
//  MxMessageState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMessageSO: MxStateObjectType {
    
    var UID: MxUID
    var id: String
    
    init(UID: MxUID?, id: String){
        self.init(UID: UID)
        self.id = id
    }
    
    init(messageSO: MxMessageSO){
        self.init(UID: messageSO.UID, id: messageSO.id)
    }
}

struct MxMessageState: MxStateType {
    var messages = [MxMessageRow]()
}


extension MxMessageSO: MxMessageRow {}

protocol MxMessageRow: MxStateObjectType {
    var id: String { get set }
}

