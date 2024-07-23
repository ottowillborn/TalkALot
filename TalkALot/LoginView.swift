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
    @State private var isShowingError: Bool = false


    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("FUCK OFF")
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
                    Button(action: {
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            guard error == nil else {
                                print("Error during login: \(error!.localizedDescription)")
                                isShowingError = true
                                return }
                            UserDefaults.standard.set(true, forKey: "signIn")

                        }
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
                    if isShowingError {
                        Text("Invalid login credentials")
                            .foregroundColor(.red)
                            .padding(.bottom, 20)
                    }
                    Spacer()
                    
                    Button(action:{
                        GoogleSignInHandler.shared.handleGoogleSignIn()
                    })
                    {
                        Text("Sign in with google")
                    }
                    .padding(20)
                    
 
                    
                    NavigationLink(destination: SignUpView()){
                        Text("Dont have an account? Click to sign up")
                    }
                    
                    Spacer()

                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }//NavigationView
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
