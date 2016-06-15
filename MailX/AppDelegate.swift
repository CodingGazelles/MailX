//
//  AppDelegate.swift
//  
//
//  Created by Tancrède on 3/4/16.
//  Copyright © 2016 HexDesign. All rights reserved.
//

import Cocoa

import ReSwift



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var syncManager = { () -> MxSyncManager in
        return MxSyncManager.defaultManager()
    }()
    
    lazy var stateManager = MxUIStateManager.defaultStore()
    lazy var dataStack = MxDataStackManager.defaultStack()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        // init logs
        MxLog.enable()
        
        
        MxLog.info("*** App launching ***")
        
        
        // Init DB
        MxLog.info("Connecting to DB")
        
        dataStack.startDBStack()
            .onSuccess { _ in
                
                if MxUserPreferences.sharedPreferences().firstExecution {
                    
                    MxDBInitializer.insertDefaultProviders()
                    
                    //            #if DEBUG
                    MxDBInitializer.insertTestMailbox()
                    //            #endif
                    
                    
                    MxUserPreferences.sharedPreferences().firstExecution = false
                    
                } else {
                    MxLog.debug("DB already initialized")
                }
                
                
                // Init AppState
                self.stateManager.initState()
                
                
                // Init connections to mailboxes
                self.syncManager.connectMailboxes()
                
            }
            .onFailure { error in
                MxLog.error( "Failed to initiate connection to DB", error: error)
            }
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification){
        MxLog.info("*** Application will terminate. Bye ***")
        
        // close db connections
        
        
        // save state
        stateManager.saveState()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
}