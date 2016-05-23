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
    
    var UID: String
    var id: MxMessageModelId
    var value: String
    var labelId: MxLabelModelId?
}

struct MxMessageModelId: MxModelIdType {
    var value: String
}
