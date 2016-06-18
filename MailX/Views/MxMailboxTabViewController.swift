//
//  MxMailboxTabsViewControler.swift
//  MailX
//
//  Created by Tancrède on 6/17/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Cocoa

import ReSwift



class MxMailboxTabViewController: NSTabViewController {

    let state = MxUIStateManager.defaultState()
    
    var mailboxes: [MxMailboxSO]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MxLog.debug("MxMailboxTabsViewController did load")
    }

}

extension MxMailboxTabViewController: StoreSubscriber {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        state.store.subscribe(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        state.store.unsubscribe(self)
    }
    
    func newState(state: MxAppState) {
        MxLog.debug("New State received by MxMailboxTabViewController: \(state)")
        
        mailboxes = Array( state.mailboxList.keys)
        
        // 1 diff between the new and the old mailbox arrays
        // 2 remove or add appropriate TabItem
        
        // 3 copy the new mailbox array in the old one
        
        
    }
    
}
