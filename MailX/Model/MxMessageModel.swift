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



final class MxMessageModel: MxModelType, MxRemotePersistable {
    
    var UID: MxUID
    var remoteId: MxMessageModelId?
    var value: String
    var labelIds: [MxLabelModelId]
    
    weak var _dbo: MxMessageDBO?
    
    init(UID: MxUID?, remoteId: MxMessageModelId, value: String, labelIds: [MxLabelModelId]){
        self.UID = UID ?? MxUID()
        self.remoteId = remoteId
        self.value = value
        self.labelIds = labelIds
    }
    
    
}


extension MxMessageModel: MxLocalPersistable {
    
    var dbo: MxMessageDBO? {
        get {
            return _dbo
        }
        set {
            _dbo = newValue
        }
    }
    
    convenience init( dbo: MxMessageDBO){
        
        let remoteId = MxMessageModelId( value: dbo.remoteId)
        let labelIds = dbo.labels
            |> map(){ MxLabelModelId( value: $0.remoteId) }
        
        self.init(
            UID: dbo.UID
            , remoteId: remoteId
            , value: "TO DO"
            , labelIds: labelIds)
        
        self.dbo = dbo
    }
    
    
    // MARK: - Insert
    
    func insert() -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Delete
    
    func delete() -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    static func delete( uids uids: [MxUID]) -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Update
    
    func update() -> Result<Bool, MxModelError> {
        fatalError("Func not implemented")
    }
    
    
    // MARK: - Fetch
    
    static func fetch( uid uid: MxUID) -> Result<MxMessageModel, MxModelError> {
        fatalError("Func not implemented")
    }
    
    static func fetch( uids uids: [MxUID]) -> Result<[Result<MxMessageModel, MxModelError>], MxDBError> {
        fatalError("Func not implemented")
    }
}

extension MxMessageModel {
    
    static func deleteMessages( mailboxUID mailboxUID: MxUID, labelCode: String)
        -> Result< Bool,MxDBError> {
            
            MxLog.debug("Processing: \(#function). Args: mailboxId=\(mailboxUID), labelId=\(labelCode)")
            
            let db = MxPersistenceManager.defaultManager().db
            
            switch fetchMessageDBOs( mailboxUID: mailboxUID, labelCode: labelCode) {
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

final class MxMessageModelId: MxRemoteId {
    var value: String
    init( value: String){
        self.value = value
    }
}

