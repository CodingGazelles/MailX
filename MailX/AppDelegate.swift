//
//  AppDelegate.swift
//
//
//  Created by Tancrède on 3/4/16.
//  Copyright © 2016 HexDesign. All rights reserved.
//

import Cocoa

import ReSwift
import BrightFutures



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var syncManager = { () -> MxSyncManager in
        return MxSyncManager.defaultManager()
    }()
    
    lazy var uiState = MxUIStateManager.defaultState()
    lazy var dataStack = MxDataStackManager.defaultStack()
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        // init logs
        MxLog.enable()
        
        
        MxLog.info("*** App launching ***")
        
        initApp()
        
    }
    
    private func initApp() {
        // Init DB
        
        Queue.global.context {
            
            MxLog.info("Connecting to DB")
            
            self.dataStack.startDBStack()
                .onSuccess { _ in
                    
                    if MxUserPreferences.sharedPreferences().firstExecution {
                        
                        MxLog.debug("Initializing DB")
                        
                        let result = MxDBInitializer.insertDefaultProviders()
                        
                        //            #if DEBUG
                        MxDBInitializer.insertTestMailbox( provider: result.value![1])
                        //            #endif
                        
                        self.dataStack.saveContext()
                        
                        MxUserPreferences.sharedPreferences().firstExecution = false
                        
                    } else {
                        MxLog.debug("DB already initialized")
                    }
                    
                    
                    // Init AppState
                    self.uiState.initState()
                    
                    
                    // Connect and refresh mailboxes
                    switch self.dataStack.getAllMailboxes() {
                        
                    case let .Success( mailboxes):
                        
                        for mailbox in mailboxes {
                            
                            self.syncManager.connectMailbox(mailbox: mailbox)
                                
                                .onSuccess {
                                    
                                    self.syncManager.refreshMailbox(mailbox: mailbox)
                                        
                                        .onSuccess {
                                            
                                            dispatchRefreshMailboxAction( mailbox: MxMailboxSO( model: mailbox))
                                            
                                        }
                                        
                                        .onFailure { error in
                                            
                                            MxLog.error( "Failed to refresh mailbox \(mailbox.email)", error: error)
                                            
                                            let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                                            
                                            self.uiState.dispatch(action)
                                            
                                    }
                                }
                                
                                .onFailure { error in
                                    
                                    MxLog.error( "Failed to connect to mailbox \(mailbox.email)", error: error)
                                    
                                    let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                                    
                                    self.uiState.dispatch(action)
                                    
                            }
                            
                        }
                        
                    case let .Failure(error):
                        
                        MxLog.error( "Failed to load mailboxes", error: error)
                        
                        let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                        
                        self.uiState.dispatch(action)
                        
                    }
                    
                    
                }
                .onFailure { error in
                    
                    MxLog.error( "Failed to initiate connection to DB", error: error)
                    
                    let action = MxAddErrorsAction(errors: [MxErrorSO(error: error)])
                    
                    self.uiState.dispatch(action)
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification){
        MxLog.info("*** Application will terminate. Bye ***")
        
        // close db connections
        dataStack.saveContext()
        
        // save state
        uiState.saveState()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
}