

import Foundation

import RealmSwift
import Result
import SugarRecordRealm


// MARK: - protocols

protocol MxDBOType: Entity {
    
    associatedtype AssociatedModel
    
}

protocol ModelConvertible: MxDBOType {
    
    func toModel() -> Result<AssociatedModel, MxDbError>
    static func fromModel( model model: AssociatedModel) -> Result<Self, MxModelError>
    
}


// Mark: - Provider

final class MxProviderDBO: Object, MxDBOType {
    
    typealias AssociatedModel = MxProviderModel
    
    // properties
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
    dynamic var id: String = ""
    
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
    dynamic var id: String = ""
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
    dynamic var id: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
}


// MARK: - ModelConvertible extension

extension MxProviderDBO: ModelConvertible {
    
    func toModel() -> Result<AssociatedModel, MxDbError> {
        preconditionFailure("Func not implemented")
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxProviderDBO, MxModelError> {
        preconditionFailure("Func not implemented")
    }
    
}

extension MxMailboxDBO: ModelConvertible {
    
    func toModel() -> Result<MxMailboxModel, MxDbError> {
        guard let provider = self.provider else {
            let error =  MxDbError.DbObjectInconsistent(object: self, errorMessage: "Mailbox without provider")
            return Result.Failure( error)
        }
        let result = MxMailboxModel(id: MxMailboxModel.Id(value: self.id), providerId: MxProviderModel.Id(value: provider.id))
        return Result.Success( result)
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxMailboxDBO, MxModelError> {
        preconditionFailure("Func not implemented")
    }
    
}

extension MxLabelDBO: ModelConvertible {
    
    func toModel() -> Result<MxLabelModel, MxDbError> {
        guard let ownerType = MxLabelModel.MxLabelOwnerType(rawValue: self.ownerType) else {
            let error = MxDbError.DbObjectInconsistent(object: self, errorMessage: "Label without identificable owner type")
            return Result.Failure( error)
        }
        guard let mailboxId = self.mailbox?.id else {
            let error = MxDbError.DbObjectInconsistent(object: self, errorMessage: "Label without mailbox id")
            return Result.Failure( error)
        }
        let result =  MxLabelModel(
            id: MxLabelModel.Id(value: self.id)
            , name: self.name
            , type: ownerType
            , mailboxId: MxMailboxModel.Id(value: mailboxId))
        return Result.Success(result)
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxLabelDBO, MxModelError> {
        preconditionFailure("Func not implemented")
    }
    
}

extension MxMessageDBO: ModelConvertible {

    func toModel() -> Result<AssociatedModel, MxDbError> {
        preconditionFailure("Func not implemented")
    }
    
    static func fromModel(model model: AssociatedModel) -> Result<MxMessageDBO, MxModelError> {
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



