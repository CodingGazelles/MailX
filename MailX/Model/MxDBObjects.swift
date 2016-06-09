

import Foundation

import RealmSwift
import Result
import SugarRecordRealm



// MARK: - Protocols

protocol MxDBOType: class, SugarRecordRealm.Entity, MxBusinessObjectProtocol {
    
    var internalId: String { get set }
    var remoteId: String { get set }
    
}

extension MxDBOType {
    
    var id: MxObjectId {
        get {
            return MxObjectId(internalId: MxInternalId(value: internalId), remoteId: MxRemoteId(value: remoteId))
        }
        set {
            self.internalId = newValue.internalId.value
            self.remoteId = newValue.remoteId.value
        }
    }

    func primaryKey() -> String? {
        return "internalId"
    }
    
//    func delete() -> Result<Bool,MxDBError> {
//        
//        let db = MxDBLevel.defaultManager().db
//        
//        do {
//            
//            try db.operation { (context, save) throws -> Void in
//                try context.remove(self)
//                save()
//            }
//            
//            return .Success( true)
//            
//        } catch {
//            
//            return .Failure(
//                MxDBError.UnableToExecuteOperation(
//                    operationType: MxDBOperation.MxDeleteOperation
//                    , DBOType: Mirror(reflecting: self).subjectType
//                    , message: "Error while calling context.remove() \(self)"
//                    , rootError: error))
//            
//        }
//    }
}


// Mark: - Provider

class MxProviderDBO: RealmSwift.Object, MxDBOType {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    
    dynamic var code: String = ""
    dynamic var name: String = ""
    
    // relationships
//    var mailboxes: [MxMailboxDBO] {
//        return linkingObjects( MxMailboxDBO.self, forProperty: "provider")
//    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}

//extension MxProviderDBO {
//    func toModel() -> Result<MxProviderModel, MxStackError> {
//        fatalError("Func not implemented")
//    }
//}


// MARK: - Mailbox

final class MxMailboxDBO : RealmSwift.Object, MxDBOType {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    
    dynamic var providerInternalId: String = ""
    dynamic var providerRemoteId: String = ""
    
    // relationships
//    dynamic var provider: MxProviderDBO!
//    var labels: [MxLabelDBO] {
//        return linkingObjects( MxLabelDBO.self, forProperty: "mailbox")
//    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
}

//extension MxMailboxDBO {
//    func toModel() -> Result<MxMailboxModel,MxStackError> {
//        
//        guard self.provider != nil else {
//            
//            let error =  MxStackError.UnableToConvertDBOToModel(
//                dbo: self
//                , message: "Mailbox without a provider"
//                , rootError: nil)
//            return Result.Failure( error)
//        }
//        
//        return Result.Success( MxMailboxModel(dbo: self)!)
//    }
//}


// MARK: - Label

final class MxLabelDBO: RealmSwift.Object, MxDBOType {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var ownerType: String = ""
    
    dynamic var mailboxInternalId: String = ""
    dynamic var mailboxRemoteId: String = ""
    
    // relationships
//    dynamic var mailbox: MxMailboxDBO!
//    var messages: [MxMessageDBO] {
//        return linkingObjects( MxMessageDBO.self, forProperty: "labels")
//    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}

//extension MxLabelDBO {
//    func toModel() -> Result<MxLabelModel, MxStackError> {
//        
//        guard MxLabelOwnerType( rawValue: self.ownerType) != nil else {
//            
//            let error =  MxStackError.UnableToConvertDBOToModel(
//                dbo: self
//                , message: "Unable to instanciate MxLabelOwnerType with MxLabelDBO with args: \(self)"
//                , rootError: nil)
//            
//            return Result.Failure( error)
//        }
//        
//        return Result.Success( MxLabelModel(dbo: self)!)
//    }
//}


// MARK: - Messages

final class MxMessageDBO: RealmSwift.Object, MxDBOType {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var labelId: String = ""
    
    dynamic var mailboxInternalId = ""
    dynamic var mailboxRemoteId = ""
    
    // relationships
//    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}

//extension MxMessageDBO {
//    func toModel() -> Result<MxMessageModel, MxStackError> {
//        fatalError("Func not implemented")
//    }
//}




