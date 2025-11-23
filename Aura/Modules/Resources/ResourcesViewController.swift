//
//  ResourcesViewController.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//

import UIKit

class ResourcesViewController: UIViewController {

    private let resourcesView = ResourcesView()

        override func loadView() {
            view = resourcesView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Resources"
            view.backgroundColor = UIColor.systemBackground
        }

}
