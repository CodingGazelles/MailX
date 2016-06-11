//
//  MxMailboxModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Result
import Pipes
import RealmSwift



final class MxMailboxModel: Object, MxModelObjectProtocol {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    dynamic var email: String = ""
    dynamic var name: String = ""
    
    // relationships
    dynamic var provider: MxProviderModel?
    let labels = LinkingObjects(fromType: MxLabelModel.self, property: "mailbox")
    let messages = LinkingObjects(fromType: MxMessageModel.self, property: "mailbox")
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["connected", "proxy"]
    }
    
    override static func primaryKey() -> String? {
        return "internalId"
    }
    
    var connected: Bool = false
    var proxy: MxMailboxProxy!

}

//class MxMailboxDBO : MxBaseDBO {
//    
//    
//    
//}

//extension MxMailboxModel: MxLocalPersistable {
//    
//    convenience init?( dbo: MxMailboxDBO){
//        
//        guard dbo.providerInternalId.characters.count > 0 || dbo.providerRemoteId.characters.count > 0 else {
//            return nil
//        }
//        
//        self.init(
//            id: dbo.id
//            , email: dbo.email
//            , name: dbo.name
//            , connected: false
//            , providerId:
//                MxObjectId(
//                    internalId: MxInternalId(value: dbo.providerInternalId),
//                    remoteId: MxRemoteId(value: dbo.providerRemoteId))
//        )
//        
//    }
//    
//    func updateDBO(dbo dbo: MxMailboxDBO) {
//        
//        dbo.id = self.id
//        
//        dbo.email = self.email
//        dbo.name = self.name
//        
//        dbo.providerInternalId = self.providerId.internalId.value
//        dbo.providerRemoteId = self.providerId.remoteId.value
//        
//    }
//    
//}

//    // MARK: - Insert
//    
//    func insert() -> Result<Bool, MxStackError> {
//        
//        MxLog.verbose("Processing: \(#function). Args: mailbox=\(self)")
//        
//        let providerCode = self.providerCode
//        //        let appProperties = MxAppProperties.defaultProperties()
//        let db = MxDBLevel.defaultManager().db
//        
//        switch fetchProviderDBO( providerCode: providerCode) {
//        case let .Success(provider):
//            
//            do {
//                try db.operation{ (context, save) throws -> Void in
//                    
//                    let newMailboxDbo: MxMailboxDBO = try context.create()
//                    
//                    newMailboxDbo.id = self.id
//                    newMailboxDbo.email = self.email
//                    newMailboxDbo.name = self.name
//                    newMailboxDbo.provider = provider
//                    
//                    save()
//                }
//                
//                return .Success(true)
//                
//            } catch {
//                
//                return Result.Failure(
//                    MxStackError.UnableToExecuteDBOperation(
//                        operationType: MxDBOperation.MxCreateOperation
//                        , DBOType: MxMailboxDBO.self
//                        , message: "Error while calling context.create on MxMailboxDBO. Args: mailbox=\(self)"
//                        , rootError: error))
//            }
//            
//        case let .Failure(error):
//            
//            return Result.Failure(
//                MxStackError.UnableToExecuteDBOperation(
//                    operationType: MxDBOperation.MxFetchOperation
//                    , DBOType: MxProviderDBO.self
//                    , message: "Error while calling fetchProviderDBO() with args: providerCode=\(providerCode)"
//                    , rootError: error))
//        }
//    }
    
    
    // MARK: - Delete
//    
//    func delete() -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    
//    // MARK: - Update
//    
//    func update() -> Result<Bool, MxStackError> {
//        fatalError("Func not implemented")
//    }
//    
//    
//    // MARK: - Fetch
//    
//    static func fetch( id id: MxObjectId) -> Result<MxMailboxModel, MxStackError> {
//        
//        switch fetchMailboxDBO( mailboxId: id) {
//            
//        case let .Success(mailbox):
//            return mailbox.toModel()
//            
//        case let .Failure(error):
//            return .Failure(
//                MxStackError.UnableToExecuteDBOperation(
//                    operationType: MxDBOperation.MxFetchOperation
//                    , DBOType: MxMailboxModel.self
//                    , message: "Error while calling fetchMailboxDBO() with args: mailboxId=\(id)"
//                    , rootError: error)
//            )
//        }
//        
//    }
//    
//    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<MxMailboxModel, MxStackError>], MxDBError> {
//        fatalError("Func not implemented")
//    }
    


//extension MxMailboxModel {
//    
//    static func fetch()
//        -> Result<[Result<MxMailboxModel, MxStackError>], MxDBError> {
//            
//            MxLog.debug("\(#function): fetching all mailboxes")
//            
//            return fetchMailboxDBOs()
//                |> map(){ $0.toModel()}
//    }
//    
//}

//extension MxMailboxModel {
//    func toSO() -> MxMailboxSO {
//        return MxMailboxSO(model: self)
//    }
//}


// MARK: - MxRemoteId

//final class MxMailboxModelId: MxRemoteId{
////    var value: String
////    init( value: String){
////        self.value = value
////    }
//}








