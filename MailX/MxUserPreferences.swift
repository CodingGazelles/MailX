//
//  MxUserPreferences.swift
//  Hexmail
//
//  Created by Tancrède on 4/3/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation



class MxUserPreferences {
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = MxUserPreferences()
    static func sharedPreferences() -> MxUserPreferences {
        return sharedInstance
    }
    
    private let kFirstExecution = "firstExecution"
    private let kDefaultProvidersInserted = "defaultProvidersInserted"
    private let kTestMailboxInserted = "testMailboxInserted"
    
    
    // MARK: - Factory defaults
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private var factoryDefaults: [String:AnyObject] {
        get {
            return [ kFirstExecution : true, kDefaultProvidersInserted: false, kTestMailboxInserted: false]
        }
    }
    
    private init() {
        registerFactoryDefaults()
        
//        let path = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        MxLog.debug("Search path is: \(path)")
        
//        MxLog.debug("User defaults: \( userDefaults.dictionaryRepresentation())")
    }
    
    func registerFactoryDefaults() {
        userDefaults.registerDefaults(factoryDefaults)
    }
    
    
    // MARK: - User prefs
    
    var firstExecution: Bool {
        get {
            return userDefaults.boolForKey( kFirstExecution)
        }
        set( show) {
            userDefaults.setBool(show, forKey: kFirstExecution)
        }
    }
    
    var defaultProvidersInserted: Bool {
        get {
            return userDefaults.boolForKey( kDefaultProvidersInserted)
        }
        set {
            userDefaults.setBool( newValue, forKey: kDefaultProvidersInserted)
        }
    }
    
    var testMailboxInserted: Bool {
        get {
            return userDefaults.boolForKey( kTestMailboxInserted)
        }
        set {
            userDefaults.setBool( newValue, forKey: kTestMailboxInserted)
        }
    }
}