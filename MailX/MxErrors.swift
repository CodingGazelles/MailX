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

enum MxStateError: MxExceptionProtocol {
    
    case BaseError( object: Any?, message: String, rootError: ErrorType)
    
}


// MARK: - Stack Error

enum MxStackError: MxExceptionProtocol {
    
    case SearchFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case InsertFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case UpdateFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case DeleteFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    
    case ModelError( object: Any?, message: String, rootError: ErrorType?)
    
    case MemoryError( object: Any?, message: String, rootError: ErrorType?)
    case DBError( object: Any?, message: String, rootError: ErrorType?)
    case NetworkError( object: Any?, message: String, rootError: ErrorType?)
    
    case UndexpectedError( object: Any?, message: String, rootError: ErrorType?)
    
}


// MARK: - DB Error

enum MxDBError: MxExceptionProtocol {

    case FetchError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case InsertError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case UpdateError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case DeleteError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    
    case UndexpectedError( object: Any?, message: String, rootError: MxExceptionProtocol?)
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


