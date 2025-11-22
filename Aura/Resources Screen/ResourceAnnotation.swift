//
//  ResourceAnnotation.swift
//  Aura
//
//  Created by Member C
//  Custom annotation for resources on map
//

import MapKit

class ResourceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let resource: MentalHealthResource
    
    init(resource: MentalHealthResource) {
        self.resource = resource
        self.coordinate = CLLocationCoordinate2D(
            latitude: resource.latitude ?? 0,
            longitude: resource.longitude ?? 0
        )
        self.title = resource.name
        self.subtitle = "\(resource.type) • \(resource.distance ?? "")"
        super.init()
    }
}
