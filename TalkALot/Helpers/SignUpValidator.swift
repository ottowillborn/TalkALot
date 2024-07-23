//
//  SignUpValidator.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-23.
//

import Foundation
import FirebaseAuth
import Firebase

class SignUpValidator {
    
     func validate(email: String, password: String, confirmPassword: String) -> (isShowingError: Bool, errorMessage: String){
        if !email.contains("@") {
            return (true, "Email is poorly formatted")
        }
        else if password.count < 8 {
            // Show error message
            return (true, "Password must be at least 8 characters long")
        } else if password != confirmPassword {
            // Show error message
            return (true, "Passwords do not match")
        } else {
            // Proceed with further actions (e.g., sign up the user)
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard error == nil else {
                    print("Error during account creation: \(error!.localizedDescription)")
                    return
                }
                UserDefaults.standard.set(true, forKey: "signIn")
            }
            return (false, "Passwords match, proceed with sign up.")
        }
    }
    
}
