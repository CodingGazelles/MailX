//
//  MxProviderModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import RealmSwift



final class MxProviderModel: Object, MxDBOProtocol, MxModelObjectProtocol {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var code: String = ""
    dynamic var name: String = ""
    
    // relationships
    let mailboxes = LinkingObjects(fromType: MxMailboxModel.self, property: "provider")
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}






