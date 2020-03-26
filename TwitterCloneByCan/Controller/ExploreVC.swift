//
//  ExploreVC.swift
//  TwitterCloneByCan
//
//  Created by Apple on 19.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserCell"

class ExploreVC: UITableViewController {
    

// MARK: - Properties

    private var users = [User]() { //we had to do something with "users" in fetchUsers function's completion block. So as soon as users is set which will be done by going to function and saying self.users = users to clarify an array; we will reloaddata for tableview. then we will jump back to UserCell. Remember, every single cell is a USER. we have to do same thing with usercell view which is creating user var then and constructing configure() after SETTING it. After POPULATING information for each cell, want to set that var "user" so that didset gets executed and we need to populate that user object belongs to each cell, we go to explorevc and go to cellforroat to say cell.user = users[i.r]
        didSet { tableView.reloadData() }
    }
    
    private var filteredUsers = [User]() { //basically filter users array based on text we put
        didSet { tableView.reloadData() }
    }
    
    private var inSearchMode: Bool { //this variable will help us determine whether or not we are searching.
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    
    private let searchController = UISearchController(searchResultsController: nil)
    
// MARK: - Lifecycle

override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    fetchUsers()
    configureSearchController()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }


// MARK: - API
    func fetchUsers() {
        UserService.shared.fetchUsers { (users) in
            self.users = users
        }
    }

// MARK: - Helpers
    
    func configureUI() {
         view.backgroundColor = .white
         navigationItem.title = "Explore"
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
     }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        
    }
}

extension ExploreVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileVC(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension ExploreVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count //damn this man genius.
    }
}

extension ExploreVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredUsers = users.filter({ $0.username.contains(searchText)}) //basically filtering users depending on entry of usernames that contains pieces of text from searchtext
    }
    
    
}
