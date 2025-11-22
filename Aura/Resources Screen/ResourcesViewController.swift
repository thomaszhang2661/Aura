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
    var distance: String?
    let latitude: Double?
    let longitude: Double?
    
    init(name: String, type: String, phone: String, description: String, distance: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.type = type
        self.phone = phone
        self.description = description
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
    }
}

class ResourcesViewController: UIViewController {

    private let resourcesView = ResourcesView()
    private let locationService = LocationService.shared
    
    // National and mock nearby resources
    private var resources: [MentalHealthResource] = []
    private var currentUserLocation: CLLocation?  // Store user location for map

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
        resourcesView.viewMapButton.addTarget(self, action: #selector(viewMapTapped), for: .touchUpInside)
        resourcesView.chatWithAuraButton.addTarget(self, action: #selector(chatWithAuraTapped), for: .touchUpInside)
    }
    
    private func loadNationalResources() {
        // MARK: Using ResourcesAPI to fetch data (like tutorial's getAllContacts)
        ResourcesAPI.shared.getAllResources { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let fetchedResources):
                // Filter only national resources for initial display
                self.resources = fetchedResources.filter { resource in
                    resource.latitude == nil && resource.longitude == nil
                }
                
                // MARK: reload table view on main thread (important for async calls)
                self.resourcesView.resourcesTableView.reloadData()
                
            case .failure(let error):
                // MARK: handle error - show alert
                print("Error loading resources: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to load resources. Please try again.")
                
                // Load fallback data
                self.loadFallbackResources()
            }
        }
    }
    
    // MARK: Fallback data in case of network failure
    private func loadFallbackResources() {
        resources = [
            MentalHealthResource(
                name: "988 Suicide & Crisis Lifeline",
                type: "24/7 Crisis Hotline",
                phone: "988",
                description: "Free and confidential support for people in distress"
            ),
            MentalHealthResource(
                name: "Crisis Text Line",
                type: "24/7 Text Support",
                phone: "741741",
                description: "Text HOME to 741741"
            ),
            MentalHealthResource(
                name: "NAMI Helpline",
                type: "Information & Support",
                phone: "1-800-950-6264",
                description: "Mental health information and resources"
            ),
            MentalHealthResource(
                name: "SAMHSA National Helpline",
                type: "Treatment Referral",
                phone: "1-800-662-4357",
                description: "Treatment referral and information service"
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
                self.currentUserLocation = loc  // Store for map view
                self.loadNearbyResources(for: loc)
            case .failure(let err):
                self.handleLocationError(err)
            }
        }
    }
    
    @objc private func viewMapTapped() {
        // Filter resources that have coordinates
        let mappableResources = resources.filter { $0.latitude != nil && $0.longitude != nil }
        
        if mappableResources.isEmpty {
            showErrorAlert(message: "No resources with locations available. Try 'Find Nearby Support' first.")
            return
        }
        
        // Present map view controller
        let mapVC = ResourceMapViewController(resources: mappableResources, userLocation: currentUserLocation)
        mapVC.modalPresentationStyle = .fullScreen
        present(mapVC, animated: true)
    }

    @objc private func chatWithAuraTapped() {
        // Emit event to open chat
        EventBus.shared.emit(.openChat)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Location Handling (using API like tutorial's details endpoint)
    private func loadNearbyResources(for location: CLLocation) {
        let lat = String(format: "%.4f", location.coordinate.latitude)
        let lon = String(format: "%.4f", location.coordinate.longitude)
        
        // Show loading
        showLoading(true)
        
        // MARK: Call API to get nearby resources
        ResourcesAPI.shared.getNearbyResources(location: location, radiusKm: 10) { [weak self] result in
            guard let self = self else { return }
            
            self.showLoading(false)
            
            switch result {
            case .success(let nearbyResources):
                // MARK: Insert nearby resources at the top (like tutorial)
                self.resources.insert(contentsOf: nearbyResources, at: 0)
                self.resourcesView.resourcesTableView.reloadData()
                
                // Show success message
                let alert = UIAlertController(
                    title: "📍 Location Found",
                    message: "Found \(nearbyResources.count) resources near:\n(\(lat), \(lon))",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
            case .failure(let error):
                print("Error loading nearby resources: \(error.localizedDescription)")
                self.showErrorAlert(message: "Could not load nearby resources. Showing national resources only.")
            }
        }
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
    
    // MARK: Error Alert Helper
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
