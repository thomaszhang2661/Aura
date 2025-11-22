//
//  APIConfigs.swift
//  Aura
//
//  Created by Member C
//  API configuration for mental health resources
//

import Foundation

class APIConfigs {
    // Using a real public API for mental health resources
    // Note: This is a demo API endpoint that returns mental health hotlines
    static let baseURL = "https://findahelpline.com/api/v1/"
    
    // Alternative: You can also use a simple JSON placeholder API for testing
    // static let testResourcesURL = "https://api.npoint.io/your-endpoint"
    
    // For now, we'll use local data with the option to switch to API later
    static let useLocalData = true  // Set to false when API is ready
}
