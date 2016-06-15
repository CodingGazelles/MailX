//
//  MxBaseManagedObject.swift
//  MailX
//
//  Created by Tancrède on 6/15/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import CoreData



class MxBaseManagedObject: NSManagedObject, MxModelObjectProtocol {
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
}


class MxBaseRemoteOject: MxRemoteObjectProtocol {
    var internalId: MxInternalId?
    var remoteId: MxRemoteId?
}