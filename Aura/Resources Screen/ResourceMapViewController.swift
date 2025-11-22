//
//  ResourceMapViewController.swift
//  Aura
//
//  Created by Member C
//  View controller to display resources on Apple Maps
//

import UIKit
import MapKit
import CoreLocation

class ResourceMapViewController: UIViewController {
    
    private let mapView = ResourceMapView()
    private var resources: [MentalHealthResource] = []
    private var userLocation: CLLocation?
    
    // MARK: - Init
    init(resources: [MentalHealthResource], userLocation: CLLocation?) {
        self.resources = resources
        self.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resources Map"
        
        mapView.mapView.delegate = self
        mapView.closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        setupMap()
    }
    
    // MARK: - Setup Map
    private func setupMap() {
        // Add annotations for resources with coordinates
        let annotations = resources.compactMap { resource -> ResourceAnnotation? in
            guard resource.latitude != nil, resource.longitude != nil else {
                return nil
            }
            return ResourceAnnotation(resource: resource)
        }
        
        mapView.mapView.addAnnotations(annotations)
        
        // Center map on user location or first resource
        if let userLoc = userLocation {
            centerMap(on: userLoc.coordinate, radius: 5000) // 5km radius
        } else if let firstAnnotation = annotations.first {
            centerMap(on: firstAnnotation.coordinate, radius: 10000) // 10km radius
        }
    }
    
    // MARK: - Map Helpers
    private func centerMap(on coordinate: CLLocationCoordinate2D, radius: Double) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        mapView.mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension ResourceMapViewController: MKMapViewDelegate {
    
    // Customize annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "ResourcePin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // Add info button to callout
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        
        // Customize pin color based on distance
        if let resourceAnnotation = annotation as? ResourceAnnotation {
            if let distanceStr = resourceAnnotation.resource.distance,
               let distanceValue = Double(distanceStr.replacingOccurrences(of: " km", with: "")) {
                if distanceValue < 2 {
                    annotationView?.markerTintColor = .systemGreen  // Very close
                } else if distanceValue < 5 {
                    annotationView?.markerTintColor = .systemBlue   // Close
                } else {
                    annotationView?.markerTintColor = .systemOrange // Far
                }
            } else {
                annotationView?.markerTintColor = .systemRed
            }
        }
        
        return annotationView
    }
    
    // Handle callout accessory tap (info button)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let resourceAnnotation = view.annotation as? ResourceAnnotation else {
            return
        }
        
        // Show detailed info
        showResourceDetail(resourceAnnotation.resource)
    }
    
    // MARK: - Show Resource Detail
    private func showResourceDetail(_ resource: MentalHealthResource) {
        var message = "\(resource.type)\n\n"
        message += "📞 \(resource.phone)\n\n"
        message += resource.description
        
        if let distance = resource.distance {
            message += "\n\n📍 Distance: \(distance)"
        }
        
        let alert = UIAlertController(title: resource.name, message: message, preferredStyle: .alert)
        
        // Call button
        alert.addAction(UIAlertAction(title: "📞 Call", style: .default) { _ in
            let phoneNumber = resource.phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        
        // Directions button
        alert.addAction(UIAlertAction(title: "🗺️ Directions", style: .default) { _ in
            self.openInMaps(resource: resource)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Open in Apple Maps
    private func openInMaps(resource: MentalHealthResource) {
        guard let lat = resource.latitude, let lng = resource.longitude else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = resource.name
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}
