//
//  FeedVC.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedVC: UICollectionViewController {
    
     // MARK: - Properties
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    
    private var tweets = [Tweet]() { //why and what: we told our collectionview to reload its data as soon as tweets gets set, so that API call inside fetchTeets function gonna complete then it's gonna say self.tweets = tweets so that didset block gets called and it's gonna reloaddata. So that reload function is basically helping us call these Collection view functions again under extensions class down there.
        didSet { collectionView.reloadData() }
    }
    
    
     // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchTweets()
        }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false //to have our navigationbar upstairs after dismissing header.

    }
    
        
    // MARK: - API
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()

        TweetService.shared.fetchTweets { (tweets) in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()

            self.collectionView.refreshControl?.endRefreshing()
            
            
            // self.tweets = tweets.sorted(by: { (tweet1, tweet2) -> Bool in
            // return tweet1.timestamp > tweet2.timestamp
            
            
        }  }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { (tweet) in
            TweetService.shared.checkIfUserLikedTweet(tweet) { (didLike) in
                guard didLike == true else { return } //if they didnt like the tweet we dont want to do anything.
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) { //find me the tweet where that tweetid is equal to tweetID of iteration we are on.
                    self.tweets[index].didLike = true
                }
                //we are inside of a for loop. it's gonna loop through each one of our tweets. then it's gonna check and see if user liked the tweet. we have didlike inside and we make sure didlike is true before we go any further. and then we need to go and modify the datasource inside of our code. we need to find the index of tweet that has been liked.
                //firstly it fetchtweets then we sort tweets and then we check if user liked the tweet. so it goes to check if user liked the tweet then it checks didLike, it checkes it's false then it goes back to next iteration of the loop,second tweet it's gonna say check and see if user liked the tweet it comes out as true and goes to if let index = ... line. SO now we need to update tweet. we go to var tweet array up at properties. we find the tweet thats been liekd and update it ($0.tweetID == tweet.tweetID }) { //find me the tweet where that tweetid is equal to tweetID of iteration we are on. So at this line firstindex guy will find that tweet.). it's gonna be stored in index property and we will be able to modify our datasource with that index array as liked.
            
        }
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTap() {
        let controller = ProfileVC(user: user!)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    
    // MARK: - Helpers
        
    func configureUI() {
        view.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        
    }
        
    func configureLeftBarButton() {
        guard let user = user else { return } //make sure user exists
        
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32/2
        profileImageView.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
    }
        
    }

// MARK: - UICollectionViewDelegate/DataSource
extension FeedVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout


extension FeedVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidht: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72 ) //72 is for default features like caption label actionstack...
    }

}

extension FeedVC: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { (user) in
            let controller = ProfileVC(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        TweetService.shared.likeTweet(tweet: tweet) { (err, ref) in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            //only upload notification if tweet is being liked
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(type: .like, tweet: tweet)
        }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet =  cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
            let controller = ProfileVC(user: user)
            navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

    
