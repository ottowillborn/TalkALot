//
//  UserProfile.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-11-18.
//
import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class UserProfile: ObservableObject {
    @Published var currentUUID: String?
    @Published var birthdate: String
    @Published var name: String
    @Published var email: String
    @Published var username: String
    @Published var profileImage: UIImage?
    @Published var bio: String?
    @Published var followers: [String]
    @Published var following: [String]


    let db = Firestore.firestore()
    
    init() {
        //self.currentUUID = Auth.auth().currentUser?.uid ?? "uuid"
        self.name = "default name"
        self.email = Auth.auth().currentUser?.email ?? "email"
        self.username = Auth.auth().currentUser?.displayName ?? "username"
        self.birthdate = "birthdate"
        self.followers = []
        self.following = []
    }
    
    func uploadProfile(){
        //uploading the profile to firestore after sign up process
        let userData: [String: Any] = [
            "name": self.name,
            "email": self.email,
            "username": self.username,
            "birthdate": self.birthdate,
            "bio": "",
            "followers": [],
            "following": []
        ]


        db.collection("users").document(Auth.auth().currentUser?.uid ?? "No user").setData(userData) { error in
            if let error = error {
                print("Error adding user: \(error.localizedDescription)")
            } else {
                print("User added successfully!")
            }
        }

        
    }
        
    func downloadProfileByUID(fetchFromUID: String){
        let userRef = db.collection("users").document(fetchFromUID)

            userRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching user profile: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    if let userData = document.data() {
                        //print("User profile fetched successfully: \(userData)")
                        self.birthdate = userData["birthdate"] as? String ?? "No birthdate provided"
                        self.name = userData["name"] as? String ?? "No name provided"
                        self.email = userData["email"] as? String ?? "No email provided"
                        self.username = userData["username"] as? String ?? "Unknown username"
                        self.bio = userData["bio"] as? String ?? "Unknown bio"
                        self.followers = userData["followers"] as? [String] ?? ["Unknown followers"]
                        self.following = userData["following"] as? [String] ?? ["Unknown following"]
                       
                    } else {
                        print("User document is empty.")
                    }
                } else {
                    print("User document does not exist.")
                }
            }
        // Get profile picture for explored user
        fetchProfilePicture(fetchFromUID: fetchFromUID) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
    
    func followUser(followedUID: String, completion: @escaping (Bool, String?) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(false, "No current user ID")
            return
        }
        
        let currentUserRef = db.collection("users").document(currentUID)
        let followedUserRef = db.collection("users").document(followedUID)
        
        // Add `followedUID` to the current user's `following` array
        currentUserRef.updateData([
            "following": FieldValue.arrayUnion([followedUID])
        ]) { error in
            if let error = error {
                completion(false, "Error updating following: \(error.localizedDescription)")
                return
            }
            
            // Add `currentUID` to the followed user's `followers` array
            followedUserRef.updateData([
                "followers": FieldValue.arrayUnion([currentUID])
            ]) { error in
                if let error = error {
                    completion(false, "Error updating followers: \(error.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    func unfollowUser(unfollowedUID: String, completion: @escaping (Bool, String?) -> Void) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            completion(false, "No current user ID")
            return
        }
        
        let currentUserRef = db.collection("users").document(currentUID)
        let unfollowedUserRef = db.collection("users").document(unfollowedUID)
        
        // Remove `unfollowedUID` from the current user's `following` array
        currentUserRef.updateData([
            "following": FieldValue.arrayRemove([unfollowedUID])
        ]) { error in
            if let error = error {
                completion(false, "Error updating following: \(error.localizedDescription)")
                return
            }
            
            // Remove `currentUID` from the unfollowed user's `followers` array
            unfollowedUserRef.updateData([
                "followers": FieldValue.arrayRemove([currentUID])
            ]) { error in
                if let error = error {
                    completion(false, "Error updating followers: \(error.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
        }
    }

}
