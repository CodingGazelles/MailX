//
//  MxStateProviderProtocols.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxProviderState {
    var providers = [MxProvider]()
    
    struct MxProvider {
        var id: String
        var name: String
        var connected: Bool
    }
}



