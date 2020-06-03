//
//  Coupon+CoreDataProperties.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//
//

import Foundation
import CoreData


extension Coupon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coupon> {
        return NSFetchRequest<Coupon>(entityName: "Coupon")
    }

    @NSManaged public var code: Int64
    @NSManaged public var discount: Double
    @NSManaged public var isUsed: Bool
    @NSManaged public var dateGenerated: String?
    @NSManaged public var owner: User?
    @NSManaged public var appliedTo: Order?

}
