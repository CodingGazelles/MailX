

import Foundation

import RealmSwift
import Result
import SugarRecordRealm



// TODO: ranger dans le bon fichier

// MARK: - Indicates that Model can be saved in local DB

protocol MxLocalPersistable {
    
    associatedtype DBO: MxDBOType
    
    init?(dbo: DBO)
    
    // Fetch
    static func fetch( uid uid: MxInternalId) -> Result<Self, MxStackError>
    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<Self, MxStackError>], MxDBError>
    
    // Insert
    func insert() -> Result<Bool,MxStackError>
    
    // Delete
    func delete() -> Result<Bool,MxStackError>
    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError>
    
    // Update
    func update() -> Result<Bool,MxStackError>
    
    
}



// MARK: - Protocols

protocol MxDBOType: class, SugarRecordRealm.Entity, MxBusinessObjectProtocol {
    
    var internalId: String { get set }
    var remoteId: String { get set }
    
    func delete() -> Result<Bool,MxDBError>
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
    
    func delete() -> Result<Bool,MxDBError> {
        
        let db = MxDBLevel.defaultManager().db
        
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
    func toModel() -> Result<Model,MxStackError>
}


// Mark: - Provider

class MxProviderDBO: RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var code: String = ""
    
    // relationships
    var mailboxes: [MxMailboxDBO] {
        return linkingObjects( MxMailboxDBO.self, forProperty: "provider")
    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "code"]
    }
}

extension MxProviderDBO {
    func toModel() -> Result<MxProviderModel, MxStackError> {
        fatalError("Func not implemented")
    }
}


// MARK: - Mailbox

final class MxMailboxDBO : RealmSwift.Object, MxDBOType, MxConvertibleToModel {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    
    // relationships
    dynamic var provider: MxProviderDBO!
    var labels: [MxLabelDBO] {
        return linkingObjects( MxLabelDBO.self, forProperty: "mailbox")
    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
}

extension MxMailboxDBO {
    func toModel() -> Result<MxMailboxModel,MxStackError> {
        
        guard self.provider != nil else {
            
            let error =  MxStackError.UnableToConvertDBOToModel(
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
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var ownerType: String = ""
    
    // relationships
    dynamic var mailbox: MxMailboxDBO!
    var messages: [MxMessageDBO] {
        return linkingObjects( MxMessageDBO.self, forProperty: "labels")
    }
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}

extension MxLabelDBO {
    func toModel() -> Result<MxLabelModel, MxStackError> {
        
        guard MxLabelOwnerType( rawValue: self.ownerType) != nil else {
            
            let error =  MxStackError.UnableToConvertDBOToModel(
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
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["_UID", "remoteId"]
    }
    
}

extension MxMessageDBO {
    func toModel() -> Result<MxMessageModel, MxStackError> {
        fatalError("Func not implemented")
    }
}




