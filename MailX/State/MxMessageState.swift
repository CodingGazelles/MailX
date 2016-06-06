//
//  MxMessageState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxMessageSO: MxStateObjectProtocol {
    
    var id: MxObjectId
    
    init(id: MxObjectId){
        self.id = id
    }
    
}

extension MxMessageSO: MxInitWithModel {
    init( model: MxMessageModel){
        self.init(id: model.id)
    }
}



//extension MxMessageSO: MxMessageRow {}
//
//protocol MxMessageRow: MxStateObjectProtocol {
//    var id: String { get set }
//}

