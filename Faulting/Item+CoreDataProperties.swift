//
//  Item+CoreDataProperties.swift
//  Faulting
//
//  Created by Bart Jacobs on 30/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var name: String?
    @NSManaged var list: List?

}
