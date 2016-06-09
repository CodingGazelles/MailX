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
    
    lazy var stateManager = MxStoreManager.defaultStore()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        // init logs
        MxLog.enable()
        
        
        //
        MxLog.info("*** App launching ***")
        
        
        // Init DB
        if MxUserPreferences.sharedPreferences().firstExecution {
            
            MxLog.info("Initializing DB")
            
            MxDBInitializer.insertDefaultProviders()
            
//            #if DEBUG
            
            MxDBInitializer.insertTestMailbox()
            
//            #endif
            
            
            MxUserPreferences.sharedPreferences().firstExecution = false
            
        } else {
            MxLog.debug("DB already initialized")
        }
        
        
        // Init AppState
        stateManager.initState()
        
        
        // Init local db and connections to providers
        let queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async( queue, {
            
            MxLog.info("Starting syncronization")
            self.syncManager.startSynchronization()
        })
        
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