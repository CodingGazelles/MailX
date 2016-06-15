//
//  MxProvider+CoreDataProperties.swift
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

extension MxProvider {

    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var internal_id: String?
    @NSManaged var remote_id: String?
    @NSManaged var mailboxes_: NSSet?

}
