//
//  MxSetStateAction.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



struct MxSetStateAction: MxAction {
    var state: MxAppState
}

extension MxAppState {
    
    static func readSavedState() -> MxAppState? {
        return MxStateArchiver.loadSavedState()
    }
    
    static func saveState(){
        fatalError("func not implemented")
    }
    
}
