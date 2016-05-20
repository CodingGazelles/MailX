//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxLabelState: MxStateType {
    
    var allLabels = [MxLabel]()
    var labelDisplay = MxLabelDisplay.All
    
    struct MxLabel: MxStateType {
        
        var id: String
        var code: String
        var name: String
        var type: MxLabelOwnerType
        
        enum MxLabelOwnerType: String {
            case SYSTEM = "SYSTEM"
            case USER = "USER"
        }
    }
    
    enum MxLabelDisplay {
        case All
        case Selection
    }
    
}

//MARK: Extensions

extension MxLabelState.MxLabel: MxLabelRow {}

protocol MxLabelRow {
    var code: String { get set }
    var name: String { get set }
}





