//
//  MxMessageState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation


struct MxMessageState {
    var messages = [MxMessageRow]()
    
    struct MxMessage {
        var id: String
    }
}



extension MxMessageState.MxMessage: MxMessageRow {}

protocol MxMessageRow {
    var id: String { get set }
}

