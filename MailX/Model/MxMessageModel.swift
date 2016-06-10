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
import RealmSwift



final class MxMessageModel: Object, MxDBOProtocol, MxModelObjectProtocol {
    
    // properties
    dynamic var internalId: String = ""
    dynamic var remoteId: String = ""
    
    // relationships
    let labels = List<MxLabelModel>()
    dynamic var mailbox: MxMailboxModel?
    
    override static func indexedProperties() -> [String] {
        return ["internalId", "remoteId"]
    }
    
}


//extension MxMessageModel: MxLocalPersistable {
//    
//    convenience init( dbo: MxMessageDBO){
//        
//        let id = dbo.id
//        
//        self.init(
//            id: id
//            , value: "TO DO")
//        
//    }
//    func updateDBO(dbo dbo: MxMessageDBO) {
//        // TO DO
//    }
//    
//}

//extension MxMessageModel {
//    
//    static func deleteMessages( mailboxId mailboxId: MxObjectId, labelCode: String)
//        -> Result< Bool,MxDBError> {
//            
//            MxLog.debug("Processing: \(#function). Args: mailboxId=\(mailboxId), labelId=\(labelCode)")
//            
//            let db = MxDBLevel.defaultManager().db
//            
//            switch fetchMessageDBOs( mailboxId: mailboxId, labelCode: labelCode) {
//            case let .Success(messages):
//                
//                MxLog.debug("Deleting message(s): \(messages)")
//                
//                do {
//                    
//                    try db.operation { (context, save) throws -> Void in
//                        try context.remove(messages)
//                        save()
//                    }
//                    return .Success( true)
//                    
//                } catch {
//                    
//                    return .Failure(
//                        MxDBError.UnableToExecuteOperation(
//                            operationType: MxDBOperation.MxDeleteOperation
//                            , DBOType: MxMessageModel.self
//                            , message: "Error while calling context.remove() with args: messages\(messages)"
//                            , rootError: error))
//                }
//                
//            case let .Failure(error):
//                return .Failure(error)
//            }
//    }
//}


// MARK: - MxRemoteId

//final class MxMessageModelId: MxRemoteId {
//    var value: String
//    init( value: String){
//        self.value = value
//    }
//}

