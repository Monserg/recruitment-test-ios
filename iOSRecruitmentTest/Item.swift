//
//  Item.swift
//  iOSRecruitmentTest
//
//  Created by msm72 on 7/23/16.
//  Copyright © 2016 Snowdog. All rights reserved.
//

import Foundation
import CoreData


class Item: NSManagedObject {
    // Insert code here to add functionality to your managed object subclass
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName("Item"), insertIntoManagedObjectContext: CoreDataManager.instance.managedObjectContext)
    }
}

