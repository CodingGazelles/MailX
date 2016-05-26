//
//  MxMessageModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Pipes



struct MxMessageModel: MxModelType {
    
    var UID: MxUID
    var id: MxMessageModelId
    var value: String
    var labelIds: [MxLabelModelId]
    
    init(UID: MxUID?, id: MxMessageModelId, value: String, labelIds: [MxLabelModelId]){
        self.init(UID: UID)
        self.id = id
        self.value = value
        self.labelIds = labelIds
    }
}

struct MxMessageModelId: MxModelIdType {
    var value: String
}

extension MxMessageModel: MxInitWithDBO {
    init( dbo: MxMessageDBO){
        
        let id = MxMessageModelId( value: dbo.id)
        let labelIds = dbo.labels
            |> map(){ MxLabelModelId( value: $0.id) }
        
        self.init(
            UID: dbo.UID
            , id: id
            , value: "TO DO"
            , labelIds: labelIds)
    }
}