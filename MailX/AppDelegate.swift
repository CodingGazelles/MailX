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
    
    
    lazy var dataService = MxDataServices()
    lazy var syncService = MxSyncServices()
    lazy var store = MxStateStore()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        MxLog.verbose("...")
        // Insert code here to initialize your application

        
        // init logs
        MxLog.enable()
        
        
        //
        MxLog.info("*** App launching ***")
        
        
        // Init AppState
        store.initState()
        
        
        // Init local db and connections to providers
        let queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async( queue, {
            self.syncService.startSynchronization()
        })
        
        
        MxLog.verbose("... Done")
    }
    
    func applicationWillTerminate(aNotification: NSNotification){
        MxLog.info("*** Application will terminate. Bye ***")
        
        // close db connections
        
        
        // save state
        store.saveState()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
}