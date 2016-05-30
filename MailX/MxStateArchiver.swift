//
//  MxStateArchiver.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxStateArchiver {
    
    static func loadSavedState() -> MxAppState? {
        
//        fatalError("Func not implemented")
        return nil
        
    }
    
}

protocol MxArchivableState {
    init(state: MxArchivableState)
    
}