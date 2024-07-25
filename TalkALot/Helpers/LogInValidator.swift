//
//  LogInValidator.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-24.
//

import Foundation
import FirebaseAuth
import Firebase

class LogInValidator {
    
    func validate(email: String, password: String) -> Bool {
        if !email.contains("@") {
            return true
        }
        else if password.count < 8 {
            // Show error message
            return true
        } else {
            //Proceed with further actions (e.g., sign in the user)
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard error == nil else {
                    print("Error during login: \(error!.localizedDescription)")
                    return
                }
            }
            UserDefaults.standard.set(true, forKey: "signIn")
            return false
        }
    }
    
}
