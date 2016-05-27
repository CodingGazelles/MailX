//
//  MxLabelsViewController.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Cocoa

import ReSwift



class MxLabelsViewController : NSViewController {
    
    
    // IBOutlets
    @IBOutlet weak var tableView: NSTableView!
    
    @IBAction func displayCloseLabelsButtonTapped( sender: AnyObject){
        
    }
    
    // todo button to open and close the labels list
    var store = MxStateManager.defaultManager().store

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MxLabelsViewController: StoreSubscriber {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        store.subscribe(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        store.unsubscribe(self)
    }
    
    func newState(state: MxAppState) {
        MxLog.debug("New State receiver by MxLabelsViewController")
    }
    
}

