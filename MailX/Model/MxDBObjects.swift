

import Foundation

import RealmSwift
import Result



// MARK: - Protocols



//class MxBaseDBO: Object, MxDBOProtocol {
//    dynamic var internalId: String = ""
//    dynamic var remoteId: String = ""
//}


// Mark: - Provider

//class MxProviderDBO: MxBaseDBO {
//    
//    // properties
//    dynamic var code: String = ""
//    dynamic var name: String = ""
//    
//    // relationships
//    let mailboxes = LinkingObjects(fromType: MxMailboxDBO.self, property: "provider")
//    
//    override static func indexedProperties() -> [String] {
//        return ["internalId", "remoteId"]
//    }
//    
//}


// MARK: - Mailbox




// MARK: - Label

//class MxLabelDBO: MxBaseDBO {
//    
//    // properties
//    dynamic var code: String = ""
//    dynamic var name: String = ""
//    dynamic var ownerType: String = ""
//    
//    // relationships
//    let messages = LinkingObjects(fromType: MxMessageDBO.self, property: "label")
//    dynamic var mailbox: MxMailboxDBO?
//    
//    override static func indexedProperties() -> [String] {
//        return ["internalId", "remoteId"]
//    }
//    
//}


// MARK: - Messages

//class MxMessageDBO: MxBaseDBO {
//    
//    // properties
//    
//    
//    // relationships
//    let labels = List<MxLabelDBO>()
//    dynamic var mailbox: MxMailboxDBO?
//    
//    override static func indexedProperties() -> [String] {
//        return ["internalId", "remoteId"]
//    }
//    
//}






