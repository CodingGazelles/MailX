

import Foundation

import RealmSwift
import Result
import SugarRecordRealm



// MARK: - Protocols

protocol MxDBOType: SugarRecordRealm.Entity, MxDataObjectType {
    associatedtype AssociatedModel
}

extension MxDBOType {
    func primaryKey() -> String? {
        return "UID"
    }
}


// Mark: - Provider

final class MxProviderDBO: RealmSwift.Object, MxDBOType {
    
    typealias AssociatedModel = MxProviderModel
    
    // properties
    dynamic var UID: String = NSUUID().UUIDString
    dynamic var id: String = ""
    
    // relationships
    var mailboxes: MxMailboxDBOs {
        return linkingObjects( MxMailboxDBO.self, forProperty: "provider")
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
}


// MARK: - Mailbox

final class MxMailboxDBO : Object, MxDBOType {
    
    typealias AssociatedModel = MxMailboxModel
    
    // properties
    dynamic var UID: String = NSUUID().UUIDString
    dynamic var id: String = ""
    var name: String = ""
    
    // relationships
    dynamic var provider: MxProviderDBO?
    var labels: MxLabelDBOs {
        return linkingObjects( MxLabelDBO.self, forProperty: "mailbox")
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
}


// MARK: - Label

final class MxLabelDBO: Object, MxDBOType {
    
    typealias AssociatedModel = MxLabelModel
    
    // properties
    dynamic var UID: String = NSUUID().UUIDString
    dynamic var id: String = ""
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var ownerType: String = ""
    
    // relationships
    dynamic var mailbox: MxMailboxDBO?
    var messages: MxMessageDBOs {
        return linkingObjects( MxMessageDBO.self, forProperty: "labels")
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
}


// MARK: - Messages

final class MxMessageDBO: Object, MxDBOType {
    
    typealias AssociatedModel = MxMessageModel
    
    // properties
    dynamic var UID: String = NSUUID().UUIDString
    dynamic var id: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
}


// MARK: - ModelConvertible extension

protocol ModelConvertible: MxDBOType {
    func toModel() -> Result<AssociatedModel, MxError>
    static func fromModel( model model: AssociatedModel) -> Result<Self, MxError>
}

extension MxProviderDBO: ModelConvertible {
    
    func toModel() -> Result<MxProviderModel, MxError> {
        preconditionFailure("Func not implemented")
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxProviderDBO, MxError> {
        preconditionFailure("Func not implemented")
    }
}

extension MxMailboxDBO: ModelConvertible {
    
    func toModel() -> Result<MxMailboxModel, MxError> {
        
        guard self.provider != nil else {
            let error =  MxError.DataInconsistent(
                object: self
                , message: "Mailbox without a provider"
                , rootError: nil)
            return Result.Failure( error)
        }
        
        let result = MxMailboxModel(mailboxDBO: self)
        
        return Result.Success( result)
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxMailboxDBO, MxError> {
        preconditionFailure("Func not implemented")
    }
    
}

extension MxLabelDBO: ModelConvertible {
    
    func toModel() -> Result<MxLabelModel, MxError> {
        
        guard MxLabelModel.MxLabelOwnerType(rawValue: self.ownerType) != nil else {
            let error = MxError.DataInconsistent(
                object: self
                , message: "Label without identificable owner type"
                , rootError: nil)
            return .Failure( error)
        }
        
        guard self.mailbox?.id != nil else {
            let error = MxError.DataInconsistent(
                object: self
                , message: "Label without mailbox id"
                , rootError: nil)
            return .Failure( error)
        }
        
        guard let result =  MxLabelModel( labelDBO: self) else {
            let error = MxError.UnexpectedReturn(
                operationName: "MxLabelModel( labelDBO: MxLabelDBO)"
                , message: "Unable to instanciate a MxLabelModel"
                , rootError: nil)
            return .Failure( error)
        }
        
        return Result.Success(result)
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxLabelDBO, MxError> {
        preconditionFailure("Func not implemented")
    }
    
}

extension MxMessageDBO: ModelConvertible {

    func toModel() -> Result<AssociatedModel, MxError> {
        preconditionFailure("Func not implemented")
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxMessageDBO, MxError> {
        preconditionFailure("Func not implemented")
    }
    
}


// MARK: - Array extensions

typealias MxProviderDBOs = [MxProviderDBO]
typealias MxProviderOptDBOs = [MxProviderDBO?]

typealias MxMailboxDBOs = [MxMailboxDBO]
typealias MxMailboxOptDBOs = [MxMailboxDBO?]

typealias MxLabelDBOs = [MxLabelDBO]
typealias MxLabelOptDBOs = [MxLabelDBO?]

typealias MxMessageDBOs = [MxMessageDBO]
typealias MxMessageOptDBOs = [MxMessageDBO?]



extension Array where Element:MxMailboxDBO {
    
    func toModels() -> MxMailboxModelOptArray {
        return self.map{$0.toModel()}.map{$0.unwrap()}
    }
}

extension Array where Element:MxLabelDBO {
    
    func toModels() -> MxLabelModelOptArray {
        return self.map{$0.toModel()}.map{$0.unwrap()}
    }
    
}



