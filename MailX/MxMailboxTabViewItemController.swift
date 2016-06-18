//
//  MxMailboxViewController.swift
//  MailX
//
//  Created by Tancrède on 6/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Cocoa

import ReSwift



class MxMailboxTabViewItemController: NSViewController {
    
    let state = MxUIStateManager.defaultState()
    
    var mailbox: MxMailboxSO!
    
    @IBOutlet weak var refreshMailboxButton: NSButton!
    
    @IBAction func refreshMailboxButtonTapped( sender: AnyObject){
        dispatchRefreshMailboxLabelsAction( mailbox: mailbox)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MxLog.debug("MxMailboxTabViewItemController did load")
    }
    
}

//extension MxMailboxTabViewItemController: StoreSubscriber {
//    
//    override func viewWillAppear() {
//        super.viewWillAppear()
//        
//        state.store.subscribe(self)
//    }
//    
//    override func viewWillDisappear() {
//        super.viewWillDisappear()
//        
//        state.store.unsubscribe(self)
//    }
//    
//    func newState(state: MxAppState) {
//        MxLog.debug("New State received by MxMailboxTabViewItemController: \(state)")
//    }
//    
//}