//
//  MxLabel+CoreDataProperties.swift
//  MailX
//
//  Created by Tancrède on 6/13/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MxLabel {

    @NSManaged var remote_id: String?
    @NSManaged var internal_id: String?
    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var owner_type: String?
    @NSManaged var mailbox_: MxMailbox?
    @NSManaged var messages_: NSSet?

}
