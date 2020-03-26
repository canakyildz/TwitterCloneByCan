//
//  ProfileHeaderViewModel.swift
//  TwitterCloneByCan
//
//  Created by Apple on 21.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

//WE WILL USE THAT ENUM TO POPULATE COLLECTIONVIEWCELLS //dont forget we call it datamodel

import UIKit
import Firebase

enum ProfileFilterOptions: Int, CaseIterable { //
    
    case tweets
    case replies
    case likes
    
    var description: String { //creatig description to get back text from each one of those cells, basically helping us figure out which case we are using
    switch self {
    case .tweets: return "Tweets"
    case .replies: return "Tweets & Replies"
    case .likes: return "Likes"
    }
    }
}

struct ProfileHeaderViewModel {
    private let user: User
    
    let usernameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: " followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0 ,text: " following")
        
    }
    
    var actionButttnTitle: String? {
        //if user is current user then set to edit profile , else figure out following/not following
        if user.isCurrentUser {
            return "Edit Profile"
        }
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        if user.isFollowed {
            return "Following"
        }
        return "Loading"
    }
    
    init(user: User) {
        self.user = user
        
        self.usernameText = "@" + user.username
    }
    
    //helper func so we make it fileprivate func
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    
}
