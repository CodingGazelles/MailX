//
//  MxMailbox+CoreDataProperties.swift
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

extension MxMailbox {

    @NSManaged var internal_id: String?
    @NSManaged var remote_id: String?
    @NSManaged var email: String?
    @NSManaged var name: String?
    @NSManaged var provider_: MxProvider?
    @NSManaged var labels_: NSSet?
    @NSManaged var messages_: NSSet?

}
