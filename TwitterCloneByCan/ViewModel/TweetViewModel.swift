//
//  TweetViewModel.swift
//  TwitterCloneByCan
//
//  Created by Apple on 20.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//
//it's to help us compute things, everytime you have a computed property that has attributed texts and performing function to configure a 
import UIKit
import Firebase

struct TweetViewModel {
    
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL? {
        return tweet.user.profileImageUrl
    }
    
    var usernameText : String {
        return "@\(user.username)"
    }
    
    var retweetsAttributedString : NSAttributedString? {
        return attributedText(withValue: tweet.retweetCount, text: " Retweets")
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.likes, text: " Likes")
    }
    
    
    var userInfoText: NSAttributedString {
        
        let attributedText = NSMutableAttributedString(string: user.fullname , attributes: [.font: UIFont.boldSystemFont(ofSize: 14),])
        attributedText.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        attributedText.append(NSAttributedString(string: " ・\(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? "?m"
    }
    
    var headertimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ・ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp) //take a look at this some time later to understand this model
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
    
    //helper func so we make it fileprivate func
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    func size(forWidht widht: CGFloat) -> CGSize { //pas in some text, figure out size of text then specify for widht.
        let measurementLabel = UILabel()
        measurementLabel.text = tweet.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: widht).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    
}
