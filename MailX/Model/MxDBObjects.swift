

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

typealias MxMailboxDBOResult = Result<MxMailboxDBO, MxDBError>

final class MxMailboxDBO : Object, MxDBOType {
    
    // properties
    dynamic var _UID = ""
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
    
    // properties
    dynamic var _UID = ""
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
    
    // properties
    dynamic var _UID = ""
    dynamic var id: String = ""
    
    // relationships
    let labels = List<MxLabelDBO>()
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
}


// MARK: - ModelConvertible extension

//extension MxProviderDBO: MxModelConvertible {
//    
//    typealias AssociatedModel = MxProviderModel
//    
//    func toModel() -> Result<MxProviderModel, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//    
//    static func fromModel(model model: AssociatedModel) -> Result<MxProviderDBO, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//}

//extension MxMailboxDBO: MxModelConvertible {
//    
//    typealias AssociatedModel = MxMailboxModel
//    
//    func toModel() -> Result<MxMailboxModel, MxDBError> {
//        
//        guard self.provider != nil else {
//            let error =  MxDBError.DataInconsistent(
//                object: self
//                , message: "Mailbox without a provider")
//            return Result.Failure( error)
//        }
//        
//        let result = MxMailboxModel(dbo: self)
//        
//        return Result.Success( result)
//    }
//    
//    static func fromModel(model model: AssociatedModel) -> Result<MxMailboxDBO, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//    
//}
//
//extension MxLabelDBO: MxModelConvertible {
//    
//    typealias AssociatedModel = MxLabelModel
//    
//    func toModel() -> Result<MxLabelModel, MxDBError> {
//        
//        guard MxLabelOwnerType(rawValue: self.ownerType) != nil else {
//            let error = MxDBError.DataInconsistent(
//                object: self
//                , message: "Label without identificable owner type")
//            return .Failure( error)
//        }
//        
//        guard self.mailbox?.id != nil else {
//            let error = MxDBError.DataInconsistent(
//                object: self
//                , message: "Label without mailbox id")
//            return .Failure( error)
//        }
//        
//        guard let result =  MxLabelModel( labelDBO: self) else {
//            let error = MxDBError.DataInconsistent(
//                object: self
//                , message: "Unable to instanciate a MxLabelModel with MxLabelDBO")
//            return .Failure( error)
//        }
//        
//        return Result.Success(result)
//    }
//    
//    static func fromModel(model model: AssociatedModel) -> Result<MxLabelDBO, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//    
//}
//
//extension MxMessageDBO: MxModelConvertible {
//    
//    typealias AssociatedModel = MxMessageModel
//
//    func toModel() -> Result<AssociatedModel, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//    
//    static func fromModel(model model: AssociatedModel) -> Result<MxMessageDBO, MxDBError> {
//        preconditionFailure("Func not implemented")
//    }
//    
//}


// MARK: - Array extensions

typealias MxProviderDBOs = [MxProviderDBO]
typealias MxProviderOptDBOs = [MxProviderDBO?]

typealias MxMailboxDBOs = [MxMailboxDBO]
typealias MxMailboxOptDBOs = [MxMailboxDBO?]

typealias MxLabelDBOs = [MxLabelDBO]
typealias MxLabelOptDBOs = [MxLabelDBO?]

typealias MxMessageDBOs = [MxMessageDBO]
typealias MxMessageOptDBOs = [MxMessageDBO?]



//extension Array where Element:MxMailboxDBO {
//    
//    func toModels() -> MxMailboxModelOptArray {
//        return self.map{$0.toModel()}.map{$0.unwrap()}
//    }
//}
//
//extension Array where Element:MxLabelDBO {
//    
//    func toModels() -> MxLabelModelOptArray {
//        return self.map{$0.toModel()}.map{$0.unwrap()}
//    }
//    
//}



