//
//  Issue+CoreDataProperties.swift
//  Feedback Assistant
//
//  Created by Yaroslav Pleskach on 12/18/25.
//
//

public import Foundation
public import CoreData


public typealias IssueCoreDataPropertiesSet = NSSet

extension Issue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Issue> {
        return NSFetchRequest<Issue>(entityName: "Issue")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var content: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var title: String?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Issue {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension Issue : Identifiable {

}
