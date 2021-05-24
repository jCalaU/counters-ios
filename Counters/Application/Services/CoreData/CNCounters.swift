//
//  CNCounters+CoreDataClass.swift
//  Counters
//
//  Created by Javier Cala Uribe on 24/5/21.
//
//

import Foundation
import CoreData


public class CNCounters: NSManagedObject {

}

extension CNCounters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CNCounters> {
        return NSFetchRequest<CNCounters>(entityName: "CNCounters")
    }

    @NSManaged public var count: Int64
    @NSManaged public var id: String?
    @NSManaged public var title: String?

}
