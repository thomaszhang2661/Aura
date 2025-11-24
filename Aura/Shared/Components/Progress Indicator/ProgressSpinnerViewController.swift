//
//  ProgressSpinnerViewController.swift
//  WA8_<18>
//
//  Created by Chance Q on 11/9/25.
//

import UIKit

class ProgressSpinnerViewController: UIViewController {

    var activityIndicator: UIActivityIndicatorView!

        override func viewDidLoad() {
            super.viewDidLoad()
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .orange
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
            
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            view.addSubview(activityIndicator)
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
        }

}
