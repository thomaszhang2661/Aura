//
//  ResourceMapView.swift
//  Aura
//
//  Created by Member C
//  Map view to display resources locations visually
//

import UIKit
import MapKit

class ResourceMapView: UIView {
    
    var mapView: MKMapView!
    var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMapView()
        setupCloseButton()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.showsUserLocation = true  // 显示用户位置
        mapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapView)
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.setTitle("✕ Close", for: .normal)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 8
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 4
        closeButton.layer.shadowOpacity = 0.3
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
