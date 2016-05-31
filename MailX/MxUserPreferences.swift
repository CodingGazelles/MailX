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
    
    
    // MARK: - Factory defaults
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private var factoryDefaults: [String:AnyObject] {
        get {
            return [ kFirstExecution : true]
        }
    }
    
    private init() {
        registerFactoryDefaults()
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
}