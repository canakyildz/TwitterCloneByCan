//
//  UploadTweetViewModel.swift
//  TwitterCloneByCan
//
//  Created by Apple on 23.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//WE ARE GONNA USE THIS VIEWMODEL JUST TO HELP US BE MORE LEAN WITH OUR CODE. WE ARE GONNA BE USİNG İT TO SET OUR BUTTON TITLE, CHANGE PLACE HOLDER...

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var replyText: String? //cuz it wont be always there, it's only here in the second CASE.
    
    init(config: UploadTweetConfiguration) { //we do this because all of this things will be computed based on what configuration we passing in.}
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening?"
            shouldShowReplyLabel = false
        case .reply(let tweet): //whenever we use the reply config we will have access to tweet that we are replying to
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
        }
}
}
