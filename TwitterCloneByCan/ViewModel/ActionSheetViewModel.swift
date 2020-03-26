//
//  ActionSheetViewModel.swift
//  TwitterCloneByCan
//
//  Created by Apple on 23.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

struct ActionSheetViewModel {
    
    private let user: User
    
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        if user.isCurrentUser {
            results.append(.deleteTweet)
        } else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        
        results.append(.reportTweet)
        
        return results
    }
    
    init(user: User) {
    self.user = user
    }
    
}

enum ActionSheetOptions { //we created our data model, now we'll figure out which options will be placing in the actionsheet based on props. of user
    case follow(User)
    case unfollow(User)
    case deleteTweet
    case reportTweet
    
    var description: String { //description variable is gonna be what the text label of a cell says.
        switch self {
            
        case .follow(let user): return "Follow @\(user.username)"
            
        case .unfollow(let user): return "Unfollow @\(user.username)"
            
        case .deleteTweet: return "Delete Tweet"
            
        case .reportTweet: return "Report Tweet"
            
        
        }
        
    }
    
}
