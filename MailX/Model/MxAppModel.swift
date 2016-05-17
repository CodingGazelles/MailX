//
//  MxModel.swift
//  Hexmail
//
//  Created by Tancrède on 4/3/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation




import RxSwift



class MxAppModel {
    
    
    
    private let userPrefs = MxUserPreferences.sharedPreferences()
    private let dataService = MxDataServices()
    
    
    // MARK: - Shared instance
    
    private static let sharedInstance = MxAppModel()
    static func sharedModel() -> MxAppModel {
        return sharedInstance
    }
    
    
    // Mark: - Model
    
    private var _activeMailbox: Variable<MxMailbox?>
    var activeMailbox: Observable<MxMailbox?> {
        return _activeMailbox.asObservable()
    }
    
    var mailboxes: Observable<MxMailboxes>
    var labels: Observable<MxLabels>
    
    
    private init() {
        MxLog.debug("Initialization of model")
        
        let _mailboxes = dataService.getMailboxes()
        mailboxes = dataService.rx_getMailboxes()
        
        // get active mailbox id from user prefs
        if let activeMailboxId = userPrefs.activeMailboxIdValue {
            
            _activeMailbox = Variable<MxMailbox?>( dataService.getMailbox(mailboxId: MxMailbox.Id( value: activeMailboxId))!)
            labels = dataService.rx_getLabels( mailboxId: _activeMailbox.value!.id)
            
            // choose active mailbox arbitrarily
        } else if _mailboxes.count > 0 {
            
            _activeMailbox = Variable<MxMailbox?>( _mailboxes[0])
            userPrefs.activeMailboxIdValue = _mailboxes[0].id.value
            labels = dataService.rx_getLabels( mailboxId: _activeMailbox.value!.id)
            
            
            // no active mailbox
        } else {
            
            _activeMailbox = Variable<MxMailbox?>( nil)
            labels = Variable<MxLabels>([]).asObservable()
        }
        
        
    }
    
}