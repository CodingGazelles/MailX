

import Foundation

import RealmSwift
import Result
import SugarRecordRealm



// MARK: - Protocols

protocol MxDBOType: class, SugarRecordRealm.Entity, MxBusinessObjectType {
    var _UID: String { get set }
    
    func delete() -> Result<Bool,MxDBError>
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
    
    func delete() -> Result<Bool,MxDBError> {
        
        let db = MxPersistenceManager.defaultManager().db
        
        do {
            
            try db.operation { (context, save) throws -> Void in
                try context.remove(self)
                save()
            }
            
            return .Success( true)
            
        } catch {
            
            return .Failure(
                MxDBError.UnableToExecuteOperation(
                    operationType: MxDBOperation.MxDeleteOperation
                    , DBOType: Mirror(reflecting: self).subjectType
                    , message: "Error while calling context.remove() \(self)"
                    , rootError: error))
            
        }
    }
}

protocol MxConvertibleToModel {
    associatedtype Model: MxLocalPersistable
    func toModel() -> Result<Model,MxModelError>
}


// Mark: - Provider

class MxProviderDBO: RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
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

extension MxProviderDBO {
    func toModel() -> Result<MxProviderModel, MxModelError> {
        fatalError("Func not implemented")
    }
}


// MARK: - Mailbox

final class MxMailboxDBO : RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
    // properties
    dynamic var _UID = ""
    dynamic var remoteId: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    
    // relationships
    dynamic var provider: MxProviderDBO?
    var labels: [MxLabelDBO] {
        return linkingObjects( MxLabelDBO.self, forProperty: "mailbox")
    }
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
}

extension MxMailboxDBO {
    func toModel() -> Result<MxMailboxModel,MxModelError> {
        
        guard self.provider != nil else {
            
            let error =  MxModelError.UnableToConvertDBOToModel(
                dbo: self
                , message: "Mailbox without a provider"
                , rootError: nil)
            return Result.Failure( error)
        }
        
        return Result.Success( MxMailboxModel(dbo: self)!)
    }
}


// MARK: - Label

final class MxLabelDBO: RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
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

extension MxLabelDBO {
    func toModel() -> Result<MxLabelModel, MxModelError> {
        
        guard MxLabelOwnerType( rawValue: self.ownerType) != nil else {
            
            let error =  MxModelError.UnableToConvertDBOToModel(
                dbo: self
                , message: "Unable to instanciate MxLabelOwnerType with MxLabelDBO with args: \(self)"
                , rootError: nil)
            
            return Result.Failure( error)
        }
        
        return Result.Success( MxLabelModel(dbo: self)!)
    }
}


// MARK: - Messages

final class MxMessageDBO: RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
    // properties
    dynamic var _UID = ""
    dynamic var remoteId: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
    
}

extension MxMessageDBO {
    func toModel() -> Result<MxMessageModel, MxModelError> {
        fatalError("Func not implemented")
    }
}


// MARK: - DB Error

enum MxDBOperation {
    case MxInsertOperation
    case MxDeleteOperation
    case MxUodateOperation
    case MxFetchOperation
    case MxCreateOperation
}

enum MxDBError: MxException {
    case UnableToExecuteOperation(
        operationType: MxDBOperation
        , DBOType: Any.Type
        , message: String
        , rootError: ErrorType?)
    case DataInconsistent(
        object: MxBusinessObjectType
        , message: String)
}

