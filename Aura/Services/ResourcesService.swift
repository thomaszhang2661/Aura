//
//  ResourcesService.swift
//  Aura
//
//  Created by Member C
//  Service for fetching mental health resources from Firestore
//  NOTE: Firebase integration will be implemented by Member A
//  This file is currently a placeholder
//

import Foundation
import CoreLocation

// MARK: - Placeholder Model
struct Resource: Codable {
    var id: String?
    var name: String
    var type: String
    var phone: String
    var description: String
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var distance: String?
    var isNational: Bool?
    var website: String?
    var hours: String?
    
    var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat, longitude: lon)
    }
}

// MARK: - Placeholder Service
class ResourcesService {
    
    static let shared = ResourcesService()
    
    private init() {}
    
    // MARK: - Placeholder Methods
    // TODO: Implement with Firebase Firestore when configured by Member A
    
    func fetchAllResources(completion: @escaping (Result<[Resource], Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success([]))
        }
    }
    
    func fetchNationalResources(completion: @escaping (Result<[Resource], Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success([]))
        }
    }
    
    func fetchNearbyResources(near location: CLLocation, radiusKm: Double = 10, completion: @escaping (Result<[Resource], Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success([]))
        }
    }
    
    func addResource(_ resource: Resource, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success("placeholder-id"))
        }
    }
    
    func seedInitialResources(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success(()))
        }
    }
}
