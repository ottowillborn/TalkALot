//
//  SignUpView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String = ""
    @State private var isShowingError: Bool = false


    var body: some View {
        GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text("Sign Up")
                                .font(.system(size: 40,weight: .bold,design: .rounded))
                            Spacer()
                        }
                        .padding()
                        HStack {
                            TextField("Email", text: $email)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: geometry.size.width * 0.8)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isShowingError ? Color.red : Color.clear, lineWidth: 2)
                                )
                            Spacer()
                        }
                        .padding()
                        HStack {
                            SecureField("Password", text: $password)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: geometry.size.width * 0.8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isShowingError ? Color.red : Color.clear, lineWidth: 2)
                                )
                            Spacer()
                        }
                        .padding()
                        HStack {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: geometry.size.width * 0.8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isShowingError ? Color.red : Color.clear, lineWidth: 2)
                                )
                            Spacer()
                        }
                        .padding()
                        Button(action: {
                            if password.count < 8 {
                                // Show error message
                                errorMessage = "Password must be at least 8 characters long"
                                isShowingError = true
                            } else if password != confirmPassword {
                                // Show error message
                                errorMessage = "Passwords do not match"
                                isShowingError = true
                            } else {
                                // Proceed with further actions (e.g., sign up the user)
                                print("Passwords match, proceed with sign up.")
                                isShowingError = false
                                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                    guard error == nil else {
                                        print("Error during account creation: \(error!.localizedDescription)")
                                        return
                                    }
                                    UserDefaults.standard.set(true, forKey: "signIn")
                                }
                            }
                        }) {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200, height: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(25)
                                .shadow(color: .gray, radius: 10, x: 0, y: 10)
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

