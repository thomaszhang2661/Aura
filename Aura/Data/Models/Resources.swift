//
//  Resource.swift
//  Aura
//
//  Created by Member C
//  Data model for mental health resources
//

import Foundation
import CoreLocation

struct Resource: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let phone: String
    let description: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let isNational: Bool  // true = 全国性资源, false = 本地资源
    let website: String?
    let hours: String?
    
    // Computed property for distance (will be calculated based on user location)
    var distance: String?
    
    // Computed property for CLLocation
    var location: CLLocation? {
        guard let lat = latitude, let lng = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lng)
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         type: String,
         phone: String,
         description: String,
         address: String? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         isNational: Bool = false,
         website: String? = nil,
         hours: String? = nil,
         distance: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.phone = phone
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isNational = isNational
        self.website = website
        self.hours = hours
        self.distance = distance
    }
    
    // Firestore dictionary representation
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "type": type,
            "phone": phone,
            "description": description,
            "isNational": isNational
        ]
        
        if let address = address { dict["address"] = address }
        if let latitude = latitude { dict["latitude"] = latitude }
        if let longitude = longitude { dict["longitude"] = longitude }
        if let website = website { dict["website"] = website }
        if let hours = hours { dict["hours"] = hours }
        
        return dict
    }
    
    // Create from Firestore document
    static func from(id: String, data: [String: Any]) -> Resource? {
        guard let name = data["name"] as? String,
              let type = data["type"] as? String,
              let phone = data["phone"] as? String,
              let description = data["description"] as? String else {
            return nil
        }
        
        return Resource(
            id: id,
            name: name,
            type: type,
            phone: phone,
            description: description,
            address: data["address"] as? String,
            latitude: data["latitude"] as? Double,
            longitude: data["longitude"] as? Double,
            isNational: data["isNational"] as? Bool ?? false,
            website: data["website"] as? String,
            hours: data["hours"] as? String
        )
    }
}
