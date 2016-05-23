//
//  MxErrors.swift
//  MailX
//
//  Created by Tancrède on 5/21/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



// Mark: - Data object

protocol MxDataObjectType: Loggable {
    var UID: String { get set }
    var hashValue: Int { get }
}

extension MxDataObjectType {
    
    init( dataObject: MxDataObjectType? = nil){
        if dataObject != nil {
            UID = dataObject!.UID
        } else {
            UID = NSUUID().UUIDString
        }
    }
    
    var hashValue: Int {
        return UID.hashValue
    }
}

func ==<DataObject: MxDataObjectType>(lhs: DataObject, rhs: DataObject) -> Bool{
    return lhs.UID == rhs.UID
}


// Mark: - Error

protocol MxException: ErrorType, Loggable {}

enum MxError: MxException {
    
    // when data are incoherent or missing
    case DataInconsistent( object: MxDataObjectType?, message: String, rootError: ErrorType?)
    
    // when can continue processing
    case InternalStateIncoherent( operationName: String, message: String, rootError: ErrorType?)
    
    // when a func returns an exception
    case OperationDidThrow( operationName: String, message: String, rootError: ErrorType? )
    
    // when a func return is incoherent
    case UnexpectedReturn( operationName: String, message: String, rootError: ErrorType?)
    
    // when a call parameter is incoherent
    case UnexpectedParameter( operationName: String, message: String, rootError: ErrorType?)
}


// MARK: - Loggable

protocol Loggable: CustomDebugStringConvertible, CustomStringConvertible {}


// MARK: - CustomStringConvertible

public extension CustomStringConvertible {
    var description: String {
        return description()
    }
    
    func description(indentationLevel: Int = 0) -> String {
        
        let indentString = (0..<indentationLevel).reduce("") { tabs, _ in tabs + "\t" }
        
        var s = "\(self.dynamicType)"
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        
        if children.count == 0 {
            return "\(s) = \(description),"
        }
        
        s += " {"
        
        s = children.reduce(s) {
            reducedString, child in
            
            if let aChild = child.1 as? CustomStringConvertible {
                let childDescription = aChild.description(indentationLevel + 1)
                return reducedString + "\n\(indentString)\t\(child.0!): \(childDescription)"
            } else {
                
                return reducedString +  "\n\(indentString)\t\(child.0!): \(child.1),"
            }
        }
        
        s = s.substringToIndex(s.characters.endIndex.predecessor())
        s += "\n\(indentString)}"
        
        return s
    }
}


// MARK: - CustomDebugStringConvertible

public extension CustomDebugStringConvertible {
    var debugDescription: String {
        return debugDescription()
    }
    
    func debugDescription(indentationLevel: Int = 0) -> String {
        
        let indentString = (0..<indentationLevel).reduce("") { tabs, _ in tabs + "\t" }
        
        var s = "\(self.dynamicType)"
        
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        
        if children.count == 0 {
            return "\(s) = \(debugDescription),"
        }
        
        s += " {"
        
        s = children.reduce(s) {
            reducedString, child in
            
            if let aChild = child.1 as? CustomDebugStringConvertible {
                let childDescription = aChild.debugDescription(indentationLevel + 1)
                return reducedString + "\n\(indentString)\t\(child.0!): \(childDescription)"
            } else {
                
                return reducedString +  "\n\(indentString)\t\(child.0!): \(child.1),"
            }
        }
        
        s = s.substringToIndex(s.characters.endIndex.predecessor())
        s += "\n\(indentString)}"
        
        return s
    }
}


