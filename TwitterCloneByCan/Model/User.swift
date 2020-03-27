//
//  User.swift
//  TwitterCloneByCan
//
//  Created by Apple on 20.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

struct User {
    var fullname: String
    let username: String
    var profileImageUrl: URL?
    let email: String
    let uid: String
    var isFollowed = false
    var stats: UserRelationStats? //this is not gonna be avaliable as soon as we fetchuser. only avaliable after we fetch user. we gonna set that property on our user once API call completes.
    var bio: String?

    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid} //to determine if user is current user,it's saying if auth.auth.currentuser.uid == uid then it's currentuser.
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let profileImageURLString = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = URL(string: profileImageURLString)
            
        }
    }
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}
