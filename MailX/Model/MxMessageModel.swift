//
//  MxMessageModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Pipes



final class MxMessageModel: MxModelType, MxRemotePersistable, MxLocalPersistable {
    
    var UID: MxUID
    var remoteId: MxMessageModelId
    var value: String
    var labelIds: [MxLabelModelId]
    
    init(UID: MxUID?, remoteId: MxMessageModelId, value: String, labelIds: [MxLabelModelId]){
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.value = value
        self.labelIds = labelIds
    }
    
    convenience init( dbo: MxMessageDBO){
        
        let remoteId = MxMessageModelId( value: dbo.remoteId)
        let labelIds = dbo.labels
            |> map(){ MxLabelModelId( value: $0.remoteId) }
        
        self.init(
            UID: dbo.UID
            , remoteId: remoteId
            , value: "TO DO"
            , labelIds: labelIds)
    }
}

final class MxMessageModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}

