//
//  MainTabVC.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            //pass this user to feed controller from tab controller
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedVC else { return }
            
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
//        logUserOut()
        super.viewDidLoad()
        view.backgroundColor = .twitterBlue
        authenticateUserAndConfigureUI()
        
    }
    
    // MARK: - API
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
            UserService.shared.fetchUser(uid: uid) { (user) in
                self.user = user
            } // SET the user. and when we set it didset will be called.
        
    }
    func authenticateUserAndConfigureUI() {
        //Creating a logic to see if user was logged in or not,according to that we will keep user in main user interface or send the mback to loginvc
        if Auth.auth().currentUser == nil { //if user is not logged in
            DispatchQueue.main.async { //when you wanna present a controller over rootcontroller on the load it has to be done in the main thread.
                
                let nav = UINavigationController(rootViewController: LoginVC())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
        } else {
            configureViewControllers()
            configureUI() // we only wanna get these configurations until our user logs in.
            fetchUser()
            
        }
        
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selectors

    @objc func actionTapped() {
        guard let user = user else { return }
        let controller = UploadTweetController(user: user, config: .tweet) //cuz when we launch this from this func it's just for main menu and to uload a TWEET . not a reply.
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                            paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers() { //create all viewcontrolelrs programmatically//embedding in navigation controllers in our views.
        let feed = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = dontrepeatController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreVC()
        let nav2 = dontrepeatController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsVC()
        let nav3 = dontrepeatController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        
        let conversations = ConversationsVC()
        let nav4 = dontrepeatController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    func dontrepeatController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        return nav
        
    }
    
    
    
}
