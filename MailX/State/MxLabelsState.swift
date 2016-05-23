//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxLabelSO: MxStateObjectType {
    
    var UID: String
    var id: String
    var code: String
    var name: String
    var ownerType: MxLabelOwnerType
    
    init(id: String, code: String, name: String, ownerType: String){
        self.init()
        self.id = id
        self.code = code
        self.name = name
        self.ownerType = MxLabelOwnerType(rawValue: ownerType)!
    }
    
    init(labelSO: MxLabelSO){
        self.init(dataObject: labelSO)
        self.init(id: labelSO.id, code: labelSO.code, name: labelSO.name, ownerType: labelSO.ownerType.rawValue)
    }
    
    enum MxLabelOwnerType: String {
        case SYSTEM = "SYSTEM"
        case USER = "USER"
        case UNKNOWN
    }
}

extension MxLabelSO {
    init( labelModel: MxLabelModel){
        self.init(dataObject: labelModel)
        self.init(
            id: labelModel.id.value
            , code: labelModel.code
            , name: labelModel.name
            , ownerType: labelModel.ownerType.rawValue)
    }
}

struct MxLabelsState: MxStateType {
    
    var allLabels = [MxLabelSO]()
    var labelDisplay = MxLabelDisplay.All
    
    enum MxLabelDisplay {
        case All
        case Selection
    }
    
}

//MARK: Extensions

extension MxLabelSO: MxLabelRow {}

protocol MxLabelRow: MxStateObjectType {
    var code: String { get set }
    var name: String { get set }
}





