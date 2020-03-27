//
//  NotificationsVC.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

class NotificationsVC: UITableViewController {

    
    private let reuseIdentifier = "NotificationCell"


// MARK: - Properties

    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
// MARK: - Lifecycle

override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    fetchNotifications()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        
    }


// MARK: - API
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()

        NotificationService.shared.fetchNotifications { (notifications) in
            self.refreshControl?.endRefreshing()
            self.notifications = notifications
            
            
            for (index, notification) in notifications.enumerated() {
                if case .follow = notification.type {
                let user = notification.user
                
                UserService.shared.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
            }
            
        }
    }

    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchNotifications()
    }

    
// MARK: - Helpers
    
    func configureUI() {
         view.backgroundColor = .white
        navigationItem.title = "Notifications"
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
     }

}

// MARK: UITableViewDataSource

extension NotificationsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
  
}

extension NotificationsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else { return }
        TweetService.shared.fetchTweet(withTweetID: tweetID) { (tweet) in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

extension NotificationsVC : NotificationCellDelegate {
    func buttonTapped(_ cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = false
                
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = true
            }
            
        }
    }

    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return } //safely unwrapping. because we are making sure user exists.
        
        let controller = ProfileVC(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
