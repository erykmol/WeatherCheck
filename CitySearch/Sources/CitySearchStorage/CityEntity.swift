//
//  CityEntity.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import CoreData
import CitySearch

final class CityEntity: NSManagedObject {
    static let entityName = "CityEntity"

    @NSManaged var cityID: Int64
    @NSManaged var name: String
    @NSManaged var region: String?
    @NSManaged var country: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var lastSearchedAt: Date

    convenience init(insertInto context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context) else {
            preconditionFailure("\(Self.entityName) is missing from the context's model")
        }
        self.init(entity: entity, insertInto: context)
    }

    static func makeFetchAllRequest() -> NSFetchRequest<CityEntity> {
        NSFetchRequest<CityEntity>(entityName: entityName)
    }

    static func makeFetchRequest(id: Int) -> NSFetchRequest<CityEntity> {
        let request = makeFetchAllRequest()
        request.predicate = NSPredicate(format: "%K == %lld", #keyPath(CityEntity.cityID), Int64(id))
        request.fetchLimit = 1
        return request
    }

    static func makeFetchRequest(ids: [Int]) -> NSFetchRequest<CityEntity> {
        let request = makeFetchAllRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(CityEntity.cityID), ids.map { Int64($0) })
        return request
    }

    func update(from city: City, searchedAt date: Date) {
        cityID = Int64(city.id)
        name = city.name
        region = city.region
        country = city.country
        latitude = city.latitude
        longitude = city.longitude
        lastSearchedAt = date
    }
}
