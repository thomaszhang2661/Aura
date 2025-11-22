//
//  LocationService.swift
//  Aura
//
//  Lightweight location helper for requesting permission and a single location.
//  Created by assistant.
//

import Foundation
import CoreLocation

final class LocationService: NSObject {

    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var completion: ((Result<CLLocation, Error>) -> Void)?

    enum LocationError: LocalizedError {
        case denied
        case unavailable

        var errorDescription: String? {
            switch self {
            case .denied: return "Location access was denied."
            case .unavailable: return "Unable to obtain location."
            }
        }
    }

    private override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    /// Requests a single location. The completion will be called on the main queue.
    func requestLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        self.completion = completion
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied, .restricted:
            DispatchQueue.main.async { completion(.failure(LocationError.denied)) }
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        default:
            manager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            DispatchQueue.main.async { self.completion?(.failure(LocationError.unavailable)); self.completion = nil }
            return
        }
        DispatchQueue.main.async { self.completion?(.success(loc)); self.completion = nil }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { self.completion?(.failure(error)); self.completion = nil }
    }

    // iOS < 14
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    // iOS 14+
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
}
