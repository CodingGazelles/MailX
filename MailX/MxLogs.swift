//
//  Logs.swift
//  Hexmail
//
//  Created by Tancrède on 5/13/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import CleanroomLogger



class MxLog {
    static func enable(){
        let config = XcodeLogConfiguration(minimumSeverity: LogSeverity.Verbose)
        Log.enable(configuration: config)
    }
    static func verbose( message: String){
        Log.verbose?.message( message)
    }
    static func debug( message: String){
        Log.debug?.message(message)
    }
    static func info( message: String){
        Log.info?.message(message)
    }
    static func warn( message: String, error: Loggable? = nil){
        Log.warning?.message(message)
        if error != nil {
            Log.warning?.message("\(error)")
        }
    }
    static func error( message: String, error: Loggable? = nil){
        Log.error?.message(message)
        if error != nil {
            Log.error?.message("\(error)")
        }
    }
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
        
        if children.count == 0 && indentationLevel == 0 {
            return s
        }
        
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
        
        if children.count == 0 && indentationLevel == 0 {
            return s
        }
        
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




