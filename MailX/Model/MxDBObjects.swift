

import Foundation

import RealmSwift
import Result
import SugarRecordRealm



// MARK: - Protocols

protocol MxDBOType: SugarRecordRealm.Entity, MxDataObjectType {
    var _UID: String { get set }
}

extension MxDBOType {

    var UID: MxUID {
        get {
            return MxUID(value: _UID)
        }
        set {
            _UID = newValue.value
        }
    }

    func primaryKey() -> String? {
        return "_UID"
    }
}


// Mark: - Provider

final class MxProviderDBO: RealmSwift.Object, MxDBOType {
    
    // properties
    dynamic var _UID = ""
    dynamic var code: String = ""
    
    // relationships
    var mailboxes: [MxMailboxDBO] {
        return linkingObjects( MxMailboxDBO.self, forProperty: "provider")
    }
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "code"]
    }
    
}


// MARK: - Mailbox

typealias MxMailboxDBOResult = Result<MxMailboxDBO, MxDBError>

final class MxMailboxDBO : Object, MxDBOType {
    
    // properties
    dynamic var _UID = ""
    dynamic var remoteId: String = ""
    var name: String = ""
    
    // relationships
    dynamic var provider: MxProviderDBO?
    var labels: [MxLabelDBO] {
        return linkingObjects( MxLabelDBO.self, forProperty: "mailbox")
    }
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
}


// MARK: - Label

final class MxLabelDBO: Object, MxDBOType {
    
    // properties
    dynamic var _UID = ""
    dynamic var remoteId: String = ""
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var ownerType: String = ""
    
    // relationships
    dynamic var mailbox: MxMailboxDBO?
    var messages: [MxMessageDBO] {
        return linkingObjects( MxMessageDBO.self, forProperty: "labels")
    }
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
    
}


// MARK: - Messages

final class MxMessageDBO: Object, MxDBOType {
    
    // properties
    dynamic var _UID = ""
    dynamic var remoteId: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
    
}



