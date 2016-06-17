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
    
    lazy var uiState = MxUIStateManager.defaultStore()
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
                
                
                // COnnect to and refresh mailboxes
                switch self.dataStack.getAllMailboxes() {
                    
                case let .Success( mailboxes):
                    
                    for mailbox in mailboxes {
                        
                        self.syncManager.connectMailbox(mailbox: mailbox)
                            
                            .onSuccess {
                                
                                self.syncManager.refreshMailbox(mailbox: mailbox)
                                    
                                    .onSuccess {
                                        
                                        dispatchSetLabelsAction()
                                        dispatchSetMessagesAction()
                                        
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
    
    func applicationWillTerminate(aNotification: NSNotification){
        MxLog.info("*** Application will terminate. Bye ***")
        
        // close db connections
        
        
        // save state
        uiState.saveState()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    
}