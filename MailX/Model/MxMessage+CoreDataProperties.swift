//
//  MxMessage+CoreDataProperties.swift
//  MailX
//
//  Created by Tancrède on 6/15/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MxMessage {

    @NSManaged var internalId_: String?
    @NSManaged var remoteId_: String?
    @NSManaged var labels_: NSSet?
    @NSManaged var mailbox_: MxMailbox?

}
