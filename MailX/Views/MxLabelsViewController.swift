//
//  MxLabelsViewController.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Cocoa

import ReSwift



class MxLabelsViewController: NSViewController {
    
    let kLabelViewIdentifier = "LabelView"
    
    let state = MxStateManager.defaultStore()
    
    // IBOutlets
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var showAllLabelsButton: NSButton!
    
    var labels = [MxLabelSO]()
    var showAllLabels = false
    
    @IBAction func showAllLabelsButtonTapped( sender: AnyObject){
        switch showAllLabels {
        case true:
            state.dispatch(MxShowDefaultsLabelsAction())
        case false:
            state.dispatch(MxShowAllLabelsAction())
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MxLog.debug("MxLabelsViewController did load")
    }
}

extension MxLabelsViewController: StoreSubscriber {
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        state.store.subscribe(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        state.store.unsubscribe(self)
    }
    
    func newState(state: MxAppState) {
        MxLog.debug("New State received by MxLabelsViewController: \(state)")
        
        labels = state.labelsState.visibleLabels()
        showAllLabels = state.labelsState.showAllLabels()
        showAllLabelsButton.state = showAllLabels ? NSOnState : NSOffState
        
        tableView.reloadData()
    }
    
}

extension MxLabelsViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        MxLog.verbose("processing \(#function): \(tableView)")
        return labels.count
    }
    
}

extension MxLabelsViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        MxLog.verbose("processing \(#function): \(tableView), \(tableColumn), \(row)")
        let view = tableView.makeViewWithIdentifier( kLabelViewIdentifier, owner: self) as! NSTableCellView?
        view!.textField!.stringValue = self.labels[row].code
        
        return view
    }
}

