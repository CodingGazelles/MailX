//
//  MxModelObjects.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Foundation


// MARK: - Model error

enum MxModelError : MxError {
    case ModelObjectInconsistent( model: MxModel, errorMessage: String, rootError: ErrorType?)
}


// MARK: - Root model object

protocol MxModel {
    var id: MxModelId { get set }
}

extension MxModel {
    var hashValue: Int {
        return id.value.hashValue
    }
}

struct MxModelId: Hashable, Equatable {
    var value: String
    
    init(value: String){
        self.value = value
    }
    
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxModelId, rhs: MxModelId) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs: MxModel, rhs: MxModel) -> Bool{
    return lhs.hashValue == rhs.hashValue
}



