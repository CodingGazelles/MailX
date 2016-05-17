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
    
    private let activeMailboxIdValueKey = "activeMailboxIdValueKey"
    private let showAllLabelsKey = "showAllLabelsKey"
    
    
    // MARK: - Factory defaults
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private var factoryDefaults: [String:AnyObject] {
        get {
            return [ showAllLabelsKey : false]
        }
    }
    
    private init() {
        registerFactoryDefaults()
    }
    
    func registerFactoryDefaults() {
        userDefaults.registerDefaults(factoryDefaults)
    }
    
    
    // MARK: - User prefs
    
    var activeMailboxIdValue: String? {
        get {
            return userDefaults.stringForKey(activeMailboxIdValueKey)
        }
        set( mailboxIdValue) {
            userDefaults.setObject(mailboxIdValue, forKey: activeMailboxIdValueKey)
        }
    }

    
    var showAllLabels: Bool {
        get {
            return userDefaults.boolForKey( showAllLabelsKey)
        }
        set( show) {
            userDefaults.setBool(show, forKey: showAllLabelsKey)
        }
    }
    
}