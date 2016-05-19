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


class MxMessageModel: MxModel {
    
    var id: MxModelId
    var value: String
    var labelId: MxModelId?
    
    init(id: MxModelId, value: String, labelId: MxModelId?){
        self.id = id
        self.value = value
        self.labelId = labelId
    }
}

