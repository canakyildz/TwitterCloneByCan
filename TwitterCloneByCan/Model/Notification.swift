//
//  Notification.swift
//  TwitterCloneByCan
//
//  Created by Apple on 24.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    var tweetID: String?
    var timestamp: Date!
    var user: User
    var tweet: Tweet? //optional because sometimes notifications are not related to tweet. for example follow.
    var type: NotificationType!
    
    
    init(user: User,dictionary: [String: AnyObject]) {
        self.user = user
                
        if let tweetID = dictionary["tweedID"] as? String {
            self.tweetID = tweetID
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type) //to initalize it we put type.
        }
        
    }
}
