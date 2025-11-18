//
//  ChatViewController.swift
//  Aura
//
//  Created by Chance Q on 11/17/25.
//

import UIKit

class ChatViewController: UIViewController {
    private let chatView = ChatView()

        override func loadView() {
            view = chatView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "AI Chat"
            view.backgroundColor = UIColor.systemBackground
        }


}
