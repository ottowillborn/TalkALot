//
//  UserProfile.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-11-18.
//
import Foundation
import FirebaseStorage
import FirebaseAuth
import SwiftUI

class UserProfile: ObservableObject {
    @Published var username: String
    @Published var profileImage: UIImage?
    
    init(username: String = "username") {
        self.username = username
    }
    func loadProfile(){
        self.username = Auth.auth().currentUser?.displayName ?? "username"
        fetchProfilePicture { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
}
