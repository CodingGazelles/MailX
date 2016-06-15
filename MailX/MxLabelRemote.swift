
//
//  MxRemoteLabel.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation






class MxLabelRemote: MxBaseRemoteOject, MxLabelProtocol {
    
    var code: String?
    var name: String?
    var ownerType: MxLabelOwnerType = MxLabelOwnerType.UNDEFINED
    
}