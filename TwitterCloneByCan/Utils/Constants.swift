//
//  Constants.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import Foundation
import Firebase

let DB_REF = Database.database().reference()

let USERS_REF = DB_REF.child("users")
let TWEETS_REF = DB_REF.child("tweets")
let USER_TWEETS_REF = DB_REF.child("user-tweets")
let USER_FOLLOWERS_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")
let TWEET_REPLIES_REF = DB_REF.child("tweet-replies")
let TWEET_LIKES_REF = DB_REF.child("tweet-likes")
let USER_LIKES_REF = DB_REF.child("user-likes")
let NOTIFICATIONS_REF = DB_REF.child("notifications")
let USER_REPLIES_REF = DB_REF.child("user-replies")



let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")
