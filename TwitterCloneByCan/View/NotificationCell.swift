//
//  NotificationCell.swift
//  TwitterCloneByCan
//
//  Created by Apple on 24.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.

//fetched notifications, now to populate correct data on cells we came here to do didset thingy. after creating configure I'm now heading to create a view model due to having attributed title on the original cells.
//

import UIKit

protocol NotificationCellDelegate: class {
    func didTapProfileImage(_ cell: NotificationCell)
    func buttonTapped(_ cell: NotificationCell)
    
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var notification: Notification? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .twitterBlue
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        gesture.numberOfTapsRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(gesture)
        
        return iv
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    let notificationsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification message"
        return label
    }()
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [profileImageView,notificationsLabel])
        stack.spacing = 8
        stack.alignment = .center

        addSubview(stack)
        stack.centerY(inView: self,leftAnchor: leftAnchor, paddingLeft: 12)
        stack.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(actionButton)
        actionButton.centerY(inView: self)
        actionButton.setDimensions(width: 92, height: 32)
        actionButton.layer.cornerRadius = 32/2
        actionButton.anchor(right: rightAnchor, paddingRight: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    @objc func didTapProfileImage() {
        delegate?.didTapProfileImage(self)
    }
    
    @objc func buttonTapped() {
        delegate?.buttonTapped(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let notification = notification else { return }
        let viewModel = NotificationViewModel(notification: notification)
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
        notificationsLabel.attributedText = viewModel.notificationText
        
        actionButton.isHidden = viewModel.shouldHideFollowButton
        actionButton.setTitle(viewModel.actionButtonText, for: .normal)
    }
    
}
