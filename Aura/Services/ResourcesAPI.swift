//
//  ResourcesAPI.swift
//  Aura
//
//  Created by Member C
//  API service for fetching mental health resources
//  Based on tutorial pattern from App10
//

import Foundation
import CoreLocation

// MARK: - Response Models
struct ResourcesResponse: Codable {
    let resources: [APIResource]
}

struct APIResource: Codable {
    let id: String?
    let name: String
    let type: String
    let phone: String
    let description: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let isNational: Bool?
    let website: String?
    let hours: String?
}

class ResourcesAPI {
    
    static let shared = ResourcesAPI()
    
    private init() {}
    
    // MARK: - Get All Resources (like tutorial's 'getall' endpoint)
    func getAllResources(completion: @escaping (Result<[MentalHealthResource], Error>) -> Void) {
        
        // For demo purposes, using local data (similar to tutorial's approach)
        // You can replace this with real API call later
        
        if APIConfigs.useLocalData {
            // Return hardcoded data (like tutorial does initially)
            let resources = getLocalResources()
            DispatchQueue.main.async {
                completion(.success(resources))
            }
        } else {
            // Make real API call
            let urlString = APIConfigs.baseURL + "resources"
            
            NetworkManager.shared.fetchString(from: urlString) { result in
                switch result {
                case .success(let data):
                    // Parse response similar to tutorial
                    let names = data.components(separatedBy: "\n")
                    // Convert to MentalHealthResource objects
                    var resources: [MentalHealthResource] = []
                    // ... parsing logic
                    completion(.success(resources))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Get Nearby Resources (like tutorial's 'details' endpoint)
    func getNearbyResources(
        location: CLLocation,
        radiusKm: Double = 10,
        completion: @escaping (Result<[MentalHealthResource], Error>) -> Void
    ) {
        // For now, filter local data by distance
        getAllResources { result in
            switch result {
            case .success(let allResources):
                // Filter resources with location data
                let nearbyResources = allResources.compactMap { resource -> MentalHealthResource? in
                    // Only include resources with coordinates
                    guard let lat = resource.latitude,
                          let lng = resource.longitude else {
                        return nil
                    }
                    
                    let resourceLocation = CLLocation(latitude: lat, longitude: lng)
                    let distance = location.distance(from: resourceLocation) / 1000 // km
                    
                    guard distance <= radiusKm else { return nil }
                    
                    // Create new resource with distance
                    return MentalHealthResource(
                        name: resource.name,
                        type: resource.type,
                        phone: resource.phone,
                        description: resource.description,
                        distance: String(format: "%.1f km", distance),
                        latitude: lat,
                        longitude: lng
                    )
                }.sorted { r1, r2 in
                    // Sort by distance
                    let d1 = Double(r1.distance?.replacingOccurrences(of: " km", with: "") ?? "999") ?? 999
                    let d2 = Double(r2.distance?.replacingOccurrences(of: " km", with: "") ?? "999") ?? 999
                    return d1 < d2
                }
                
                completion(.success(nearbyResources))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Local Data (Fallback / Demo Data)
    private func getLocalResources() -> [MentalHealthResource] {
        return [
            // National resources (always show)
            MentalHealthResource(
                name: "988 Suicide & Crisis Lifeline",
                type: "24/7 Crisis Hotline",
                phone: "988",
                description: "Free and confidential support for people in distress, prevention and crisis resources",
                distance: nil
            ),
            MentalHealthResource(
                name: "Crisis Text Line",
                type: "24/7 Text Support",
                phone: "741741",
                description: "Free, 24/7 support via text message. Text HOME to 741741",
                distance: nil
            ),
            MentalHealthResource(
                name: "NAMI Helpline",
                type: "Information & Support",
                phone: "1-800-950-6264",
                description: "National Alliance on Mental Illness - information, resource referrals and support",
                distance: nil
            ),
            MentalHealthResource(
                name: "SAMHSA National Helpline",
                type: "Treatment Referral",
                phone: "1-800-662-4357",
                description: "Substance Abuse and Mental Health Services Administration",
                distance: nil
            ),
            
            // Boston area resources with coordinates
            MentalHealthResource(
                name: "Boston Medical Center - Psychiatry",
                type: "Medical Center",
                phone: "(617) 638-8000",
                description: "Comprehensive mental health services including emergency psychiatric services",
                distance: nil,
                latitude: 42.3356,
                longitude: -71.0722
            ),
            MentalHealthResource(
                name: "Massachusetts General Hospital",
                type: "Hospital",
                phone: "(617) 726-2000",
                description: "Full-service psychiatric care including inpatient and outpatient services",
                distance: nil,
                latitude: 42.3632,
                longitude: -71.0686
            ),
            MentalHealthResource(
                name: "Cambridge Health Alliance",
                type: "Community Health",
                phone: "(617) 665-1000",
                description: "Mental health and substance use services",
                distance: nil,
                latitude: 42.3736,
                longitude: -71.1097
            )
        ]
    }
}

// MARK: - Enhanced MentalHealthResource with coordinates
extension MentalHealthResource {
    init(name: String, type: String, phone: String, description: String, distance: String?, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.type = type
        self.phone = phone
        self.description = description
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var latitude: Double? {
        // Add this property to MentalHealthResource struct
        return nil
    }
    
    var longitude: Double? {
        // Add this property to MentalHealthResource struct
        return nil
    }
}
