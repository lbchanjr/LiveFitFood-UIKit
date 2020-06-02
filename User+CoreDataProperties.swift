//
//  User+CoreDataProperties.swift
//  LiveFitFood
//
//  Created by Louise Chan on 2020-06-01.
//  Copyright © 2020 Louise Chan. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var phone: String?
    @NSManaged public var password: String?
    @NSManaged public var coupons: NSSet?
    @NSManaged public var orders: NSSet?

}

// MARK: Generated accessors for coupons
extension User {

    @objc(addCouponsObject:)
    @NSManaged public func addToCoupons(_ value: Coupon)

    @objc(removeCouponsObject:)
    @NSManaged public func removeFromCoupons(_ value: Coupon)

    @objc(addCoupons:)
    @NSManaged public func addToCoupons(_ values: NSSet)

    @objc(removeCoupons:)
    @NSManaged public func removeFromCoupons(_ values: NSSet)

}

// MARK: Generated accessors for orders
extension User {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)

}
