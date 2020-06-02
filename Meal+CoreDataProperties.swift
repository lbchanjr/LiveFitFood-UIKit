//
//  Meal+CoreDataProperties.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-01.
//  Copyright © 2020 Louise Chan. All rights reserved.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var name: String?
    @NSManaged public var calories: Double
    @NSManaged public var photo: String?
    @NSManaged public var mealkits: NSSet?

}

// MARK: Generated accessors for mealkits
extension Meal {

    @objc(addMealkitsObject:)
    @NSManaged public func addToMealkits(_ value: Mealkit)

    @objc(removeMealkitsObject:)
    @NSManaged public func removeFromMealkits(_ value: Mealkit)

    @objc(addMealkits:)
    @NSManaged public func addToMealkits(_ values: NSSet)

    @objc(removeMealkits:)
    @NSManaged public func removeFromMealkits(_ values: NSSet)

}
