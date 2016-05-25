//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



struct MxLabelSO: MxStateObjectType {
    
    var UID: MxUID
    var id: String?
    var code: String
    var name: String
    var ownerType: String
    
    init(){
        self.init()
    }
    
    init?(UID: MxUID?, id: String?, code: String, name: String, ownerType: String){
        
        guard MxLabelOwnerType(rawValue: ownerType) != nil else {
            return nil
        }
        
        self.init(UID: UID)
        self.id = id
        self.code = code
        self.name = name
        self.ownerType = ownerType
    }
    
    init(labelSO: MxLabelSO){
        self.init(
            UID: labelSO.UID
            , id: labelSO.id
            , code: labelSO.code
            , name: labelSO.name
            , ownerType: labelSO.ownerType)!
    }
}

extension MxLabelSO {
    init( labelModel: MxLabelModel){
        self.init(
            UID: labelModel.UID
            , id: labelModel.id.value
            , code: labelModel.code
            , name: labelModel.name
            , ownerType: labelModel.ownerType.rawValue)!
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





