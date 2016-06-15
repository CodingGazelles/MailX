//
//  MxErrors.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// MARK: - Business Objects

protocol MxCoreBusinessProtocol: class {
    var remoteId: MxRemoteId? { get set }
}

protocol MxCoreProviderProtocol: MxCoreBusinessProtocol {
    
    var code: String? { get set }
    var name: String? { get set }
//    var mailboxes: NSSet { get }
    
}

protocol MxCoreMailboxProtocol: MxCoreBusinessProtocol {
    
    var email: String? { get set }
    var name: String? { get set }
//    var messages: NSSet { get }
//    var labels: NSSet { get }
    
}

protocol MxCoreLabelProtocol: MxCoreBusinessProtocol {
    
    var code: String? { get set }
    var name: String? { get set }
    var ownerType: MxLabelOwnerType { get set }
//    var mailbox: MxMailboxProtocol? { get set }
//    var messages: NSSet { get }
    
}

protocol MxCoreMessageProtocol: MxCoreBusinessProtocol {
}


protocol MxInitWithCoreBusinessProtocol {
    associatedtype CoreBO: MxCoreBusinessProtocol
    init(bo: CoreBO)
}



