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
    
    var mailboxes = [MxMailboxSO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MxLog.debug("MxMailboxTabViewController did load")
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
        
        let newMailboxArray = Array( state.mailboxList.keys)
        
        // 1 diff between the new and the old mailbox arrays
        let diffMailboxes = diff(before: mailboxes, after: newMailboxArray)
        
        
        // 2 remove or add appropriate TabItem
        for ope in diffMailboxes {
            
            switch ope.type {
            case .Insert:
                
                let _ = ope.elements.map { element in
                    
                    let controller = self.storyboard?.instantiateControllerWithIdentifier("MailboxItemVC") as! MxMailboxTabViewItemController
                    
                    controller.mailbox = element
                    
                    let tabViewItem = NSTabViewItem()
                    tabViewItem.identifier = element.email!
                    tabViewItem.label = element.email!
                    tabViewItem.viewController = controller
                    
                    addTabViewItem(tabViewItem)
                    
                }
            
            case .Delete:
                
                tabViewItems = tabViewItems.filter{ item in
                    !ope.elements.map{ $0.email! }.contains( item.identifier as! String)
                }
                
            default:
                break
            }
            
        }
        
        
        // 3 copy the new mailbox array in the old one
        mailboxes = newMailboxArray
        
    }
    
}


