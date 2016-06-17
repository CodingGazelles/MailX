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
    //    case DataInconsistent( object: MxSystemObjectProtocol?, message: String, rootError: ErrorType?)
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
//    case BaseError( object: Any?, message: String, rootError: ErrorType)
    case UnknownAction( action: MxAction?, message: String)
}

enum MxNoError: ErrorType {}


// MARK: - Stack Error

enum MxStackError: MxExceptionProtocol {
    
    case SetupFailed( message: String, rootError: ErrorType?)
    
    case SearchFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case InsertFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case UpdateFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    case DeleteFailed( object: Any?, typeName: String, message: String, rootError: ErrorType?)
    
    case MemoryError( object: Any?, message: String, rootError: ErrorType?)
    case DBError( object: Any?, message: String, rootError: ErrorType?)
    
    case UndexpectedError( object: Any?, message: String, rootError: ErrorType?)
    
}


// MARK: - DB Error

//enum MxDBError: MxExceptionProtocol {
//
//    case FetchError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
//    case InsertError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
//    case UpdateError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
//    case DeleteError( object: Any?, typeName: String, message: String, rootError: ErrorType?)
//    
//    case UndexpectedError( object: Any?, message: String, rootError: MxExceptionProtocol?)
//}


// MARK: - Sync Error


enum MxSyncError: MxExceptionProtocol {
    case OperationFailed( message: String, rootError: ErrorType?)
    case BatchOperationFailed( message: String, rootErrors: [ErrorType]?)
    case NetworkError( error: MxNetworkError, message: String, rootError: ErrorType?)
    case UndexpectedError( object: Any?, message: String, rootError: MxExceptionProtocol?)
}

enum MxNetworkError {
    case ConnectError
    case FetchError
    case InsertError
    case UpdateError
    case DeleteError
}


// MARK: - Proxy error

enum MxProxyError: MxExceptionProtocol {
    case AdapterDidNotConnect( rootError: MxAdapterError)
    case AdapterDidNotFetchLabels( rootError: MxAdapterError)
    case AdapterReturnedError( rootError: MxAdapterError)
}


// MARK: - Network operation error

enum MxCommandError: MxExceptionProtocol {

}


// MARK: - Adapter error

enum MxAdapterError: MxExceptionProtocol {
    case ProviderReturnedConnectionError( rootError: ErrorType)
    case ProviderReturnedFetchError( rootError: ErrorType)
}







