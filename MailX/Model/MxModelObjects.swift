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
    case ModelObjectInconsistent( modelObject: MxModelObject, errorMessage: String, rootError: ErrorType?)
}


// MARK: - Root model object

protocol MxModelObject {}


//MARK: - Provider

typealias MxProviders = [MxProvider]
typealias MxProviderOpts = [MxProvider?]


class MxProvider: MxModelObject {
    
    struct Id {
        var value: String
        
        init(value: String){
            self.value = value
        }
    }
    
    var id: Id
    
    init(id: Id){
        self.id = id
    }
}

extension MxProvider : Hashable {
    var hashValue: Int {
        return id.value.hashValue
    }
}

extension MxProvider.Id : Hashable {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxProvider, rhs: MxProvider) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs: MxProvider.Id, rhs: MxProvider.Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


//MARK: - Mailbox

typealias MxMailboxes = [MxMailbox]
typealias MxMailboxeOpts = [MxMailbox?]


class MxMailbox : MxModelObject {
    
    struct Id {
        var value: String
        
        init(value: String){
            self.value = value
        }
    }
    
    var id: Id
    var providerId: MxProvider.Id
    
    init(id: Id, providerId: MxProvider.Id){
        self.id = id
        self.providerId = providerId
    }
}

extension MxMailbox : Hashable {
    var hashValue: Int {
        return id.value.hashValue
    }
}

extension MxMailbox.Id : Hashable {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxMailbox, rhs: MxMailbox) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs: MxMailbox.Id, rhs: MxMailbox.Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


//MARK: - Label

typealias MxLabels = [MxLabel]
typealias MxLabelOpts = [MxLabel?]


class MxLabel: MxModelObject {
    
    enum MxLabelOwnerType: String {
        case SYSTEM = "SYSTEM"
        case USER = "USER"
    }
    
    struct Id {
        var value: String
        
        init(value: String){
            self.value = value
        }
    }
    
    var id: Id
    var name: String
    var type: MxLabelOwnerType
    var mailboxId: MxMailbox.Id
    
    init(id: Id, name: String, type: MxLabelOwnerType, mailboxId: MxMailbox.Id){
        self.id = id
        self.name = name
        self.type = type
        self.mailboxId = mailboxId
    }
}

extension MxLabel : Hashable {
    var hashValue: Int {
        return id.value.hashValue
    }
}

extension MxLabel.Id : Hashable {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxLabel, rhs: MxLabel) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs: MxLabel.Id, rhs: MxLabel.Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}


//MARK: - Message

typealias MxMessages = [MxMessage]
typealias MxMessageOpts = [MxMessage?]


class MxMessage: MxModelObject {
    
    struct Id {
        var value: String
    }
    
    var id: Id
    var value: String
    var labelId: MxLabel.Id?
    
    init(id: Id, value: String, labelId: MxLabel.Id?){
        self.id = id
        self.value = value
        self.labelId = labelId
    }
}

extension MxMessage : Hashable {
    var hashValue: Int {
        return id.value.hashValue
    }
}

extension MxMessage.Id : Hashable {
    var hashValue: Int {
        return value.hashValue
    }
}

func ==(lhs: MxMessage, rhs: MxMessage) -> Bool{
    return lhs.hashValue == rhs.hashValue
}

func ==(lhs: MxMessage.Id, rhs: MxMessage.Id) -> Bool{
    return lhs.hashValue == rhs.hashValue
}