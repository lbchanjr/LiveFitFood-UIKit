//
//  Order+CoreDataProperties.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-03.
//  Copyright © 2020 Louise Chan. All rights reserved.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var datetime: NSDate?
    @NSManaged public var number: Int64
    @NSManaged public var tip: Double
    @NSManaged public var total: Double
    @NSManaged public var buyer: User?
    @NSManaged public var item: Mealkit?
    @NSManaged public var discount: Coupon?

}
