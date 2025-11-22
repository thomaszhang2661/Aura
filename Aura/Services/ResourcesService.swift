//
//  ResourcesService.swift
//  Aura
//
//  Created by Member C
//  Service for fetching mental health resources from Firestore
//

import Foundation
import FirebaseFirestore
import CoreLocation

class ResourcesService {
    
    static let shared = ResourcesService()
    private let db = Firestore.firestore()
    private let collectionName = "resources"
    
    private init() {}
    
    // MARK: - Fetch All Resources
    
    /// Fetch all resources (national + local)
    func fetchAllResources(completion: @escaping (Result<[Resource], Error>) -> Void) {
        db.collection(collectionName)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let resources = documents.compactMap { doc -> Resource? in
                    Resource.from(id: doc.documentID, data: doc.data())
                }
                
                completion(.success(resources))
            }
    }
    
    // MARK: - Fetch National Resources
    
    /// Fetch only national resources (hotlines)
    func fetchNationalResources(completion: @escaping (Result<[Resource], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("isNational", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let resources = documents.compactMap { doc -> Resource? in
                    Resource.from(id: doc.documentID, data: doc.data())
                }
                
                completion(.success(resources))
            }
    }
    
    // MARK: - Fetch Nearby Resources
    
    /// Fetch resources near a location (within radius in km)
    /// Note: This is a client-side filter since Firestore doesn't support geoqueries natively
    /// For production, consider using Firebase GeoFire or similar
    func fetchNearbyResources(
        near location: CLLocation,
        radiusKm: Double = 10,
        completion: @escaping (Result<[Resource], Error>) -> Void
    ) {
        db.collection(collectionName)
            .whereField("isNational", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                // Parse all resources
                var resources = documents.compactMap { doc -> Resource? in
                    Resource.from(id: doc.documentID, data: doc.data())
                }
                
                // Filter by distance and calculate distance
                resources = resources.compactMap { resource in
                    guard let resourceLocation = resource.location else { return nil }
                    
                    let distance = location.distance(from: resourceLocation) / 1000 // Convert to km
                    
                    // Only return if within radius
                    guard distance <= radiusKm else { return nil }
                    
                    // Create new resource with distance info
                    var updatedResource = resource
                    updatedResource.distance = String(format: "%.1f km", distance)
                    return updatedResource
                }
                
                // Sort by distance
                resources.sort { r1, r2 in
                    guard let d1 = r1.distance, let d2 = r2.distance else { return false }
                    return d1 < d2
                }
                
                completion(.success(resources))
            }
    }
    
    // MARK: - Add Resource (for admin/setup)
    
    /// Add a new resource to Firestore
    func addResource(_ resource: Resource, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection(collectionName).document()
        
        docRef.setData(resource.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(docRef.documentID))
            }
        }
    }
    
    // MARK: - Seed Data (for initial setup)
    
    /// Seed initial resources into Firestore (call this once to populate database)
    func seedInitialResources(completion: @escaping (Result<Void, Error>) -> Void) {
        let resources: [Resource] = [
            // National Resources
            Resource(
                name: "988 Suicide & Crisis Lifeline",
                type: "24/7 Crisis Hotline",
                phone: "988",
                description: "Free and confidential support for people in distress, prevention and crisis resources",
                isNational: true,
                website: "https://988lifeline.org",
                hours: "24/7"
            ),
            Resource(
                name: "Crisis Text Line",
                type: "24/7 Text Support",
                phone: "741741",
                description: "Free, 24/7 support via text message. Text HOME to 741741",
                isNational: true,
                website: "https://www.crisistextline.org",
                hours: "24/7"
            ),
            Resource(
                name: "NAMI Helpline",
                type: "Information & Support",
                phone: "1-800-950-6264",
                description: "National Alliance on Mental Illness - information, resource referrals and support",
                isNational: true,
                website: "https://www.nami.org",
                hours: "Mon-Fri 10am-10pm ET"
            ),
            Resource(
                name: "SAMHSA National Helpline",
                type: "Treatment Referral",
                phone: "1-800-662-4357",
                description: "Substance Abuse and Mental Health Services Administration - treatment referral and information",
                isNational: true,
                website: "https://www.samhsa.gov",
                hours: "24/7"
            ),
            
            // Boston Area Local Resources (example data)
            Resource(
                name: "Boston Medical Center - Psychiatry",
                type: "Medical Center",
                phone: "(617) 638-8000",
                description: "Comprehensive mental health services including emergency psychiatric services",
                address: "85 E Concord St, Boston, MA 02118",
                latitude: 42.3356,
                longitude: -71.0722,
                isNational: false,
                website: "https://www.bmc.org",
                hours: "24/7 Emergency"
            ),
            Resource(
                name: "Massachusetts General Hospital - Psychiatry",
                type: "Hospital",
                phone: "(617) 726-2000",
                description: "Full-service psychiatric care including inpatient and outpatient services",
                address: "55 Fruit St, Boston, MA 02114",
                latitude: 42.3632,
                longitude: -71.0686,
                isNational: false,
                website: "https://www.massgeneral.org",
                hours: "24/7 Emergency"
            ),
            Resource(
                name: "The Counseling Center",
                type: "Counseling Clinic",
                phone: "(617) 555-0100",
                description: "Individual and group therapy for anxiety, depression, and trauma",
                address: "123 Commonwealth Ave, Boston, MA 02215",
                latitude: 42.3505,
                longitude: -71.0944,
                isNational: false,
                hours: "Mon-Fri 9am-7pm"
            )
        ]
        
        // Add all resources
        let group = DispatchGroup()
        var hasError: Error?
        
        for resource in resources {
            group.enter()
            addResource(resource) { result in
                if case .failure(let error) = result {
                    hasError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = hasError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
