//
//  Tag+CoreDataProperties.swift
//  Feedback Assistant
//
//  Created by Yaroslav Pleskach on 12/18/25.
//
//

public import Foundation
public import CoreData


public typealias TagCoreDataPropertiesSet = NSSet

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var issues: NSSet?

}

// MARK: Generated accessors for issues
extension Tag {

    @objc(addIssuesObject:)
    @NSManaged public func addToIssues(_ value: Issue)

    @objc(removeIssuesObject:)
    @NSManaged public func removeFromIssues(_ value: Issue)

    @objc(addIssues:)
    @NSManaged public func addToIssues(_ values: NSSet)

    @objc(removeIssues:)
    @NSManaged public func removeFromIssues(_ values: NSSet)

}

extension Tag : Identifiable {

}
