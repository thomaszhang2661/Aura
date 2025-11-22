//
//  ResourcesViewController.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//  Member C - Resources Module
//

import UIKit
import CoreLocation

// MARK: - Inline LocationService (Temporary until file is properly added to Xcode project)
final class LocationService: NSObject, CLLocationManagerDelegate {
    
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
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

// MARK: - Resource Model
struct MentalHealthResource {
    let name: String
    let type: String
    let phone: String
    let description: String
    let distance: String?
}

class ResourcesViewController: UIViewController {

    private let resourcesView = ResourcesView()
    private let locationService = LocationService.shared
    
    // National and mock nearby resources
    private var resources: [MentalHealthResource] = []

    override func loadView() {
        view = resourcesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resources"
        view.backgroundColor = UIColor.systemBackground
        
        setupTableView()
        setupButtonActions()
        loadNationalResources()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        resourcesView.resourcesTableView.delegate = self
        resourcesView.resourcesTableView.dataSource = self
    }
    
    private func setupButtonActions() {
        resourcesView.findNearbyButton.addTarget(self, action: #selector(findNearbyTapped), for: .touchUpInside)
        resourcesView.chatWithAuraButton.addTarget(self, action: #selector(chatWithAuraTapped), for: .touchUpInside)
    }
    
    private func loadNationalResources() {
        // National hotlines and resources
        resources = [
            MentalHealthResource(
                name: "988 Suicide & Crisis Lifeline",
                type: "24/7 Crisis Hotline",
                phone: "988",
                description: "Free and confidential support for people in distress",
                distance: nil
            ),
            MentalHealthResource(
                name: "Crisis Text Line",
                type: "24/7 Text Support",
                phone: "Text HOME to 741741",
                description: "Free, 24/7 support via text message",
                distance: nil
            ),
            MentalHealthResource(
                name: "NAMI Helpline",
                type: "Information & Support",
                phone: "1-800-950-NAMI (6264)",
                description: "Mental health information and resources",
                distance: nil
            ),
            MentalHealthResource(
                name: "SAMHSA National Helpline",
                type: "Treatment Referral",
                phone: "1-800-662-4357",
                description: "Treatment referral and information service",
                distance: nil
            )
        ]
        resourcesView.resourcesTableView.reloadData()
    }

    // MARK: - Button Actions
    @objc private func findNearbyTapped() {
        // Request location permission first
        locationService.requestAuthorizationIfNeeded()
        
        showLoading(true)
        locationService.requestLocation { [weak self] result in
            guard let self = self else { return }
            self.showLoading(false)
            switch result {
            case .success(let loc):
                self.loadNearbyResources(for: loc)
            case .failure(let err):
                self.handleLocationError(err)
            }
        }
    }

    @objc private func chatWithAuraTapped() {
        // Emit event to open chat
        EventBus.shared.emit(.openChat)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Location Handling
    private func loadNearbyResources(for location: CLLocation) {
        let lat = String(format: "%.4f", location.coordinate.latitude)
        let lon = String(format: "%.4f", location.coordinate.longitude)
        
        // Mock nearby resources - in real app would use Google Places API or similar
        let mockNearby = [
            MentalHealthResource(
                name: "Hope Counseling Center",
                type: "Mental Health Clinic",
                phone: "(555) 123-4567",
                description: "Professional counseling and therapy services",
                distance: "0.8 km"
            ),
            MentalHealthResource(
                name: "Community Wellness Clinic",
                type: "Healthcare Facility",
                phone: "(555) 987-6543",
                description: "Medical and mental health services",
                distance: "1.2 km"
            ),
            MentalHealthResource(
                name: "Mindful Living Center",
                type: "Support Group",
                phone: "(555) 456-7890",
                description: "Group therapy and meditation classes",
                distance: "2.3 km"
            )
        ]
        
        // Insert nearby resources at the top
        resources.insert(contentsOf: mockNearby, at: 0)
        resourcesView.resourcesTableView.reloadData()
        
        // Show success message
        let alert = UIAlertController(
            title: "📍 Location Found",
            message: "Showing resources near:\n(\(lat), \(lon))",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func handleLocationError(_ error: Error) {
        let nsErr = error as NSError
        var message = error.localizedDescription
        if nsErr.domain == "CLKit" || (error as? LocationService.LocationError) == .denied {
            message = "Location permission denied. Please enable location access in Settings to find nearby resources."
        }

        let alert = UIAlertController(title: "Location Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    private func showLoading(_ loading: Bool) {
        resourcesView.findNearbyButton.isEnabled = !loading
        if loading {
            resourcesView.findNearbyButton.setTitle("🔍 Locating...", for: .disabled)
        } else {
            resourcesView.findNearbyButton.setTitle("📍 Find Nearby Support", for: .normal)
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath)
        let resource = resources[indexPath.row]
        
        var title = resource.name
        if let distance = resource.distance {
            title += " (\(distance))"
        }
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(resource.type) • \(resource.phone)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let resource = resources[indexPath.row]
        showResourceDetail(resource)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Resources"
    }
    
    private func showResourceDetail(_ resource: MentalHealthResource) {
        var message = "\(resource.type)\n\n"
        message += "📞 \(resource.phone)\n\n"
        message += resource.description
        
        let alert = UIAlertController(title: resource.name, message: message, preferredStyle: .alert)
        
        // Call button
        alert.addAction(UIAlertAction(title: "📞 Call", style: .default) { _ in
            // Extract numbers from phone string
            let phoneNumber = resource.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
