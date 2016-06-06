//
//  MxMessageModel.swift
//  MailX
//
//  Created by Tancrède on 5/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import Pipes
import Result



final class MxMessageModel: MxModelObjectProtocol {
    
    var id: MxObjectId
    var value: String
    var labelIds: [MxObjectId]
    
    init( id: MxObjectId, value: String, labelIds: [MxObjectId]){
        self.id = id
        self.value = value
        self.labelIds = labelIds
    }
}


extension MxMessageModel: MxLocalPersistable {
    
    convenience init( dbo: MxMessageDBO){
        
        let id = dbo.id
        
        let labelIds = dbo.labels
            |> map(){ $0.id }
        
        self.init(
            id: id
            , value: "TO DO"
            , labelIds: labelIds)
        
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Delete
    
    func delete() -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    static func delete( uids uids: [MxInternalId]) -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Update
    
    func update() -> Result<Bool, MxStackError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Fetch
    
    static func fetch( uid uid: MxInternalId) -> Result<MxMessageModel, MxStackError> {
        fatalError("Func not implemented")
    }
    
    static func fetch( uids uids: [MxInternalId]) -> Result<[Result<MxMessageModel, MxStackError>], MxDBError> {
        fatalError("Func not implemented")
    }
}

extension MxMessageModel {
    
    static func deleteMessages( mailboxId mailboxId: MxObjectId, labelCode: String)
        -> Result< Bool,MxDBError> {
            
            MxLog.debug("Processing: \(#function). Args: mailboxId=\(mailboxId), labelId=\(labelCode)")
            
            let db = MxDBLevel.defaultManager().db
            
            switch fetchMessageDBOs( mailboxId: mailboxId, labelCode: labelCode) {
            case let .Success(messages):
                
                MxLog.debug("Deleting message(s): \(messages)")
                
                do {
                    
                    try db.operation { (context, save) throws -> Void in
                        try context.remove(messages)
                        save()
                    }
                    return .Success( true)
                    
                } catch {
                    
                    return .Failure(
                        MxDBError.UnableToExecuteOperation(
                            operationType: MxDBOperation.MxDeleteOperation
                            , DBOType: MxMessageModel.self
                            , message: "Error while calling context.remove() with args: messages\(messages)"
                            , rootError: error))
                }
                
            case let .Failure(error):
                return .Failure(error)
            }
    }
}


// MARK: - MxRemoteId

//final class MxMessageModelId: MxRemoteId {
//    var value: String
//    init( value: String){
//        self.value = value
//    }
//}

