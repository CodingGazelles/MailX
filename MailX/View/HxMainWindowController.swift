//
//  HxMainWindowController.swift
//  HexaMail
//
//  Created by Tancrède on 2/14/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

import Cocoa
import Foundation


import CocoaLumberjack
import CocoaLumberjackSwift


class HxMainWindowController : NSWindowController {

    @IBOutlet weak var  labelsViewPlaceholder: NSView!
    @IBOutlet weak var  messagesViewPlaceholder: NSView!
    @IBOutlet weak var  editorViewPlaceholder: NSView!
    
    private var labelsViewController: HxLabelsViewController!
    
    //@property (readonly) StackViewController    *stackViewController;
    //@property (readonly) EditViewController     *editViewController;
    

    
    func setSubViews() {
        DDLogVerbose("... Processing")
        
        let labelsViewController = HxLabelsViewController()
        self.labelsViewController = labelsViewController
        
        DDLogVerbose("... Done")
    }
    
    func setModel( dataController dataController: HxDataController) {
        DDLogVerbose("... Processing")
        
        let labelsViewModel = HxLabelsViewModel(dataController: dataController)
        labelsViewController.setModel( labelsViewModel: labelsViewModel)
        
        DDLogVerbose("... Done")
    }
    
    override func windowDidLoad() {
        DDLogVerbose("... Processing");
    
        super.windowDidLoad()
    
        addSubview(labelsViewController.view, toView: labelsViewPlaceholder)
        //    [self addSubview:[self.stackViewController view] toView:self.stackViewPlaceholder];
        //    [self addSubview:[self.editViewController view] toView:self.editViewPlaceholder];
    
        DDLogVerbose("... Done");
    }
    
    func addSubview( insertedView: NSView, toView containerView: NSView) {
        
        let bindings = ["insertedView": insertedView]
        
        containerView.addSubview( insertedView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[insertedView]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: bindings))
        
        containerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[insertedView]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: bindings))
    
        containerView.displayIfNeeded()
    }
    
}
