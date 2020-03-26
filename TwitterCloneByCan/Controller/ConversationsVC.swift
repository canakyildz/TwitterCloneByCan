//
//  ConversationsVC.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class ConversationsVC: UIViewController {


// MARK: - Properties

// MARK: - Lifecycle

override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
}


// MARK: - Selectors

// MARK: - Helpers
    func configureUI() {
         view.backgroundColor = .white
        navigationItem.title = "Conversations"
         
     }
    
}
