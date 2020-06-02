//
//  Mealkit+CoreDataProperties.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-01.
//  Copyright © 2020 Louise Chan. All rights reserved.
//
//

import Foundation
import CoreData


extension Mealkit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mealkit> {
        return NSFetchRequest<Mealkit>(entityName: "Mealkit")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var photo: String?
    @NSManaged public var price: Double
    @NSManaged public var sku: String?
    @NSManaged public var meals: NSSet?
    @NSManaged public var orders: NSSet?

}

// MARK: Generated accessors for meals
extension Mealkit {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

// MARK: Generated accessors for orders
extension Mealkit {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)

}
