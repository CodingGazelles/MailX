//
//  MxLabelState.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result



// MARK: - State Object

typealias MxLabelSOResult = Result<MxLabelSO, MxErrorSO>

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

extension MxLabelSO: MxInitWithModel {
    init( model: MxLabelModel){
        self.init(
            UID: model.UID
            , id: model.id.value
            , code: model.code
            , name: model.name
            , ownerType: model.ownerType.rawValue)!
    }
}

func toSO( label label: MxLabelModelResult) -> MxLabelSOResult {
    switch label {
    case let .Success(model):
        return Result.Success( MxLabelSO(model: model))
    case let .Failure( error):
        return Result.Failure( errorSO(error: error))
    }
}


// MARK: - State

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





