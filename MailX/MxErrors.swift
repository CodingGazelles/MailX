//
//  MxErrors.swift
//  MailX
//
//  Created by Tancrède on 6/5/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



protocol MxExceptionProtocol: ErrorType, Loggable {}

enum MxError: MxExceptionProtocol {
    
    //    // when data are incoherent or missing
    //    case DataInconsistent( object: MxBusinessObjectProtocol?, message: String, rootError: ErrorType?)
    //
    //    // when can continue processing
    //    case InternalStateIncoherent( operationName: String, message: String, rootError: ErrorType?)
    //
    //    // when a func returns an exception
    //    case OperationDidThrow( operationName: String, message: String, rootError: ErrorType? )
    //
    //    // when a func return is incoherent
    //    case UnexpectedReturn( operationName: String, message: String, rootError: ErrorType?)
    //
    //    // when a call parameter is incoherent
    //    case UnexpectedParameter( operationName: String, message: String, rootError: ErrorType?)
}


// MARK: - Stack Error

enum MxStackError: MxExceptionProtocol {
    
    case ModelObjectNotFound( id: MxObjectId, message: String?, rootError: MxExceptionProtocol?)
    case UndexpectedError( object: Any, message: String?, rootError: MxExceptionProtocol?)
    case ModelError( object: Any, message: String?, rootError: MxExceptionProtocol?)
    case MemoryError( object: Any, message: String?, rootError: MxExceptionProtocol?)
    case DBError( object: Any, message: String?, rootError: MxExceptionProtocol?)
    case NetworkError( object: Any, message: String?, rootError: MxExceptionProtocol?)
    
}


// MARK: - DB Error

enum MxDBOperation {
    case MxInsertOperation
    case MxDeleteOperation
    case MxUodateOperation
    case MxFetchOperation
    case MxCreateOperation
}

enum MxDBError: MxExceptionProtocol {
    
    case UnableToExecuteOperation(
        operationType: MxDBOperation
        , DBOType: Any.Type
        , message: String
        , rootError: ErrorType?)
    
    case DataInconsistent(
        object: MxBusinessObjectProtocol
        , message: String)
    
    case UnableToConvertDBOToModel(
        dbo: MxDBOType
        , message: String
        , rootError: ErrorType?)
    
    case UnableToExecuteDBOperation(
        operationType: MxDBOperation
        , DBOType: Any.Type
        , message: String
        , rootError: ErrorType?)
}


// MARK: - Proxy error

enum MxProxyError: MxExceptionProtocol {
    case BridgeReturnedError( rootError: MxBridgeError)
}


// MARK: - Network operation error

enum MxRemoteOperationError: MxExceptionProtocol {

}


// MARK: - Bridge error

enum MxBridgeError: MxExceptionProtocol {
    case ProviderReturnedConnectionError( rootError: ErrorType)
    case ProviderReturnedFetchError( rootError: ErrorType)
}


