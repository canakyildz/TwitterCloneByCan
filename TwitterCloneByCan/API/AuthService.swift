//
//  AuthService.swift
//  TwitterCloneByCan
//
//  Created by Apple on 20.03.2020.
//  Copyright © 2020 PHYSID. All rights reserved.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion) //
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let username = credentials.username
        let fullname = credentials.fullname
        
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
               
               let filename = NSUUID().uuidString //creating filename uniquely in storage
               
               let storageRef = STORAGE_PROFILE_IMAGES.child(filename) //storage ref
        
        //put our image to firebase storage
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
         storageRef.downloadURL { (url, error) in //getting download url for prof.img
                guard let profileImageUrl = url?.absoluteString else { return }
                
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    guard let uid = result?.user.uid else { return } //this uid has to come back as a property of that "result" here. so we put it here.
                    
                    let values = ["email": email,
                                   "username": username,
                                   "fullname": fullname,
                                   "profileImageUrl": profileImageUrl]
                    
                    //we needda upload imageurl first
                    //result about the user we upload to firebase once we register them.
                    USERS_REF.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    }
                }
            }
        }

        
    }

