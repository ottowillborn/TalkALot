//
//  GoogleSignInHandler.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-25.
//

import Foundation
import Firebase
import GoogleSignIn

class GoogleSignInHandler {
    static let shared = GoogleSignInHandler()
    
    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { result, error in
            guard error == nil else {
                print("Error during Google sign-in: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Error during Google sign-in: \(error!.localizedDescription)")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    // Firebase auth error
                    print("Firebase auth error: \(error!.localizedDescription)")
                    return
                }
                print("Signing user in...")
                UserDefaults.standard.set(true, forKey: "signIn")
            }
        }
         func getRootViewController() -> UIViewController {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                fatalError("Unable to get the window scene")
            }
            guard let rootViewController = scene.windows.first?.rootViewController else {
                fatalError("Unable to get the root view controller")
            }
            return rootViewController
        }
    }
}
