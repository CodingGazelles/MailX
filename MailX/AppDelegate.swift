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
    
    lazy var syncManager = { () -> MxSyncManager? in
        
        switch MxSyncManager.defaultManager() {
        case let .Success(manager):
            return manager
            
        case let .Failure(error):
            MxLog.error("Unable to get an instance of the sync manager", error: error)
            return nil
        }
        
    }()
    
    lazy var stateManager = MxStateManager.defaultManager()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        // init logs
        MxLog.enable()
        
        
        //
        MxLog.info("*** App launching ***")
        
        
        // Init DB
        if MxUserPreferences.sharedPreferences().firstExecution {
            MxDBInitializer.insertDefaultProviders()
            MxUserPreferences.sharedPreferences().firstExecution = false
        } else {
            MxLog.info("DB already initialized")
        }
        
        
        // Init AppState
        stateManager.initState()
        
        
        // Init local db and connections to providers
        if syncManager != nil {
            
            let queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            dispatch_async( queue, {
                self.syncManager!.startSynchronization()
            })
            
        } else {
            MxLog.error("Unable to start syncronization because sync manager is nil", error: nil)
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