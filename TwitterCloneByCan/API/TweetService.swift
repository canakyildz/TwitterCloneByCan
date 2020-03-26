//
//  TweetService.swift
//  TwitterCloneByCan
//
//  Created by Apple on 20.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import Foundation
import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(Error?, DatabaseReference) -> Void ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = [
            "uid": uid,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0,
            "caption": caption] as [String: Any] //these all are strings and the values can be represented as ANY data type.
        
        switch type {
        case .tweet:
            TWEETS_REF.childByAutoId().updateChildValues(values) { (error, ref) in
                // update user-tweet structure after tweet upload completes.
                guard let tweetID = ref.key else { return }
                USER_TWEETS_REF.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
            
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username //adding replyingTo to values dictionary.
            
            TWEET_REPLIES_REF.child(tweet.tweetID).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyKey = ref.key else { return }
                USER_REPLIES_REF.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
            }
        }
        
        
    
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        
        var tweets = [Tweet]()
        TWEETS_REF.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]() //we need to actually append tweets to this array  so we can execute that completion handler in the function.
        USER_TWEETS_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            TWEETS_REF.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { (user) in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }            }
        }
        
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        TWEETS_REF.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
        guard let dictionary = snapshot.value as? [String: Any] else { return }
        guard let uid = dictionary["uid"] as? String else { return }
        
        UserService.shared.fetchUser(uid: uid) { (user) in
            let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
            completion(tweet)
        }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void ) {
        var replies = [Tweet]()
        
        USER_REPLIES_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            TWEET_REPLIES_REF.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { (user) in
                    let tweet = Tweet(user: user, tweetID: tweetKey, dictionary: dictionary)
                    replies.append(tweet)
                    completion(replies)
                }
            }
            
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        TWEET_REPLIES_REF.child(tweet.tweetID).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    
    
    
    func fetchLikes(forUser user: User,completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        USER_LIKES_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { (likedTweet) in
                var tweet = likedTweet //mutable copy of a tweet.
                tweet.didLike = true
                
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        TWEETS_REF.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            USER_LIKES_REF.child(uid).child(tweet.tweetID).removeValue { (err, ref) in
                TWEET_LIKES_REF.child(tweet.tweetID).child(uid).removeValue()
            }
            
        } else {
            //like tweet
            USER_LIKES_REF.child(uid).updateChildValues([tweet.tweetID: 1]) { (err, ref) in
                TWEET_LIKES_REF.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
            
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
}
