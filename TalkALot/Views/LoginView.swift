//
//  Login.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text("Weclome")
                                .font(.system(size: 40,weight: .bold,design: .rounded))
                            Spacer()
                        }
                        .padding()
                        HStack {
                            TextField("Email", text: $email)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: geometry.size.width * 0.8) // Example to use 80% of the width
                            Spacer()
                        }
                        .padding()
                        HStack {
                            SecureField("Password", text: $password)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: geometry.size.width * 0.8) // Example to use 80% of the width
                            Spacer()
                        }
                        .padding()
                        Button(action: {
                            print("Button tapped!")
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200, height: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(25)
                                .shadow(color: .gray, radius: 10, x: 0, y: 10)
                        }
                        Spacer()
                        Button(action: {
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
                                let idToken = user.idToken?.tokenString
                              else {
                                  print("Error during Google sign-in: \(error!.localizedDescription)")
                                  return
                              }

                              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                             accessToken: user.accessToken.tokenString)

                                Auth.auth().signIn(with: credential){result, error in
                                    guard error == nil else{
                                        // Firebase auth error
                                        return
                                    }
                                    print("Signing user in...")
                                    UserDefaults.standard.set(true, forKey: "signIn")

                                }
                            }
                        }) {
                            Text("Sign in with google")
                                
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

