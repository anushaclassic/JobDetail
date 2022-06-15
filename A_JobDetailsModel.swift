//
//  A_SearchList.swift
//
//  Created by Palak Jain on 22/02/18
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class A_JobDetailsModel: NSCoding {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let updated = "updated"
        static let position = "position"
        static let workingTypeDisplayName = "workingTypeDisplayName"
        static let id = "id"
        static let industryDisplayName = "industryDisplayName"
        static let created = "created"
        static let published = "published"
        static let externalId = "externalId"
        static let title = "title"
        static let subtitle = "subtitle"
        static let companyLogo = "companyLogo"
        static let companyName = "companyName"
        static let locationName = "locationName"
        static let description = "description"
        static let favorite = "favorite"
    }
    
    // MARK: Properties
    public var updated: Int?
    public var position: [Float]?
    public var workingTypeDisplayName: String?
    public var id: String?
    public var industryDisplayName: String?
    public var created: Int?
    public var published: Int?
    public var externalId: String?
    public var title: String?
    public var subtitle: String?
    public var companyLogo: String?
    public var companyName: String?
    public var locationName: String?
    public var description: String?
    public var favorite: Bool?
    
    
    
    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        updated = json[SerializationKeys.updated].int
        if let items = json[SerializationKeys.position].array { position = items.map { $0.floatValue } }
        workingTypeDisplayName = json[SerializationKeys.workingTypeDisplayName].string
        id = json[SerializationKeys.id].string
        industryDisplayName = json[SerializationKeys.industryDisplayName].string
        created = json[SerializationKeys.created].int
        published = json[SerializationKeys.published].int
        externalId = json[SerializationKeys.externalId].string
        title = json[SerializationKeys.title].string
        subtitle = json[SerializationKeys.subtitle].string
        companyLogo = json[SerializationKeys.companyLogo].string
        companyName = json[SerializationKeys.companyName].string
        locationName = json[SerializationKeys.locationName].string
        description = json[SerializationKeys.description].string
        favorite = json[SerializationKeys.favorite].bool
        
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = updated { dictionary[SerializationKeys.updated] = value }
        if let value = position { dictionary[SerializationKeys.position] = value }
        if let value = workingTypeDisplayName { dictionary[SerializationKeys.workingTypeDisplayName] = value }
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = industryDisplayName { dictionary[SerializationKeys.industryDisplayName] = value }
        if let value = created { dictionary[SerializationKeys.created] = value }
        if let value = published { dictionary[SerializationKeys.published] = value }
        if let value = externalId { dictionary[SerializationKeys.externalId] = value }
        if let value = title { dictionary[SerializationKeys.title] = value }
        if let value = subtitle { dictionary[SerializationKeys.subtitle] = value }
        if let value = companyLogo { dictionary[SerializationKeys.companyLogo] = value }
        if let value = companyName { dictionary[SerializationKeys.companyName] = value }
        if let value = locationName { dictionary[SerializationKeys.locationName] = value }
        if let value = locationName { dictionary[SerializationKeys.description] = value }
        if let value = locationName { dictionary[SerializationKeys.favorite] = value }
        
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.updated = aDecoder.decodeObject(forKey: SerializationKeys.updated) as? Int
        self.position = aDecoder.decodeObject(forKey: SerializationKeys.position) as? [Float]
        self.workingTypeDisplayName = aDecoder.decodeObject(forKey: SerializationKeys.workingTypeDisplayName) as? String
        self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
        self.industryDisplayName = aDecoder.decodeObject(forKey: SerializationKeys.industryDisplayName) as? String
        self.created = aDecoder.decodeObject(forKey: SerializationKeys.created) as? Int
        self.published = aDecoder.decodeObject(forKey: SerializationKeys.published) as? Int
        self.externalId = aDecoder.decodeObject(forKey: SerializationKeys.externalId) as? String
        self.title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
        self.subtitle = aDecoder.decodeObject(forKey: SerializationKeys.subtitle) as? String
        self.companyLogo = aDecoder.decodeObject(forKey: SerializationKeys.companyLogo) as? String
        self.companyName = aDecoder.decodeObject(forKey: SerializationKeys.companyName) as? String
        self.locationName = aDecoder.decodeObject(forKey: SerializationKeys.locationName) as? String
        self.description = aDecoder.decodeObject(forKey: SerializationKeys.description) as? String
        self.favorite = aDecoder.decodeObject(forKey: SerializationKeys.favorite) as? Bool
        
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(updated, forKey: SerializationKeys.updated)
        aCoder.encode(position, forKey: SerializationKeys.position)
        aCoder.encode(workingTypeDisplayName, forKey: SerializationKeys.workingTypeDisplayName)
        aCoder.encode(id, forKey: SerializationKeys.id)
        aCoder.encode(industryDisplayName, forKey: SerializationKeys.industryDisplayName)
        aCoder.encode(created, forKey: SerializationKeys.created)
        aCoder.encode(published, forKey: SerializationKeys.published)
        aCoder.encode(externalId, forKey: SerializationKeys.externalId)
        aCoder.encode(title, forKey: SerializationKeys.title)
        aCoder.encode(subtitle, forKey: SerializationKeys.subtitle)
        aCoder.encode(companyLogo, forKey: SerializationKeys.companyLogo)
        aCoder.encode(companyName, forKey: SerializationKeys.companyName)
        aCoder.encode(locationName, forKey: SerializationKeys.locationName)
        aCoder.encode(description, forKey: SerializationKeys.description)
        aCoder.encode(favorite, forKey: SerializationKeys.favorite)
        
    }
    
}

