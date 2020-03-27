//
//  NotificationService.swift
//  TwitterCloneByCan
//
//  Created by Apple on 24.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import Foundation
import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil, user: User? = nil )  {//no completion for notifications thank you god//default value of nil and optional becausewe wont always need that shit.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970), //var values because we will append to this if tweetID needed.
                                     "uid": uid,
                                     "type": type.rawValue] //we want to append tweetID value to values if needed (type1,2)
        
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            NOTIFICATIONS_REF.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let user = user {
            NOTIFICATIONS_REF.child(user.uid).childByAutoId().updateChildValues(values)
            
        }
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void ) {
        var notifications = [Notification]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(uid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    
}
