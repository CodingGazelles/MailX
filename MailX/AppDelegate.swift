//
//  AppDelegate.swift
//  
//
//  Created by Tancrède on 3/4/16.
//  Copyright © 2016 HexDesign. All rights reserved.
//

import Cocoa






@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
//    private var mainWindowController: MxMainWindowController!
    private var dataService = MxDataServices()
    private var syncService = MxSyncServices()
    
    
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        MxLog.verbose("...")
        // Insert code here to initialize your application

        
        // init logs
        MxLog.enable()
        
        
        //
        MxLog.info("*** App launching ***")
        
        
        
        // Init local db and connections to providers
        let queue: dispatch_queue_t = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async( queue, {
            self.syncService.startSynchronization()
        })
        
        
        MxLog.verbose("... Done")
    }
    
    func applicationWillTerminate(aNotification: NSNotification){
        MxLog.info("*** Application will terminate. Bye ***")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
}