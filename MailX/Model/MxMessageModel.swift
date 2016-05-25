//
//  MxMessageModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



typealias MxMessageModelArray = [MxMessageModel]
typealias MxMessageModelOptArray = [MxMessageModel?]

struct MxMessageModel: MxModelType {
    
    var UID: MxUID
    var id: MxMessageModelId
    var value: String
    var labelId: MxLabelModelId?
    
    init(UID: MxUID?, id: MxMessageModelId, value: String, labelId: MxLabelModelId?){
        self.init(UID: UID)
        self.id = id
        self.value = value
        self.labelId = labelId
    }
}

struct MxMessageModelId: MxModelIdType {
    var value: String
}
