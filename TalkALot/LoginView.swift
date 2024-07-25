//
//  Login.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingError: Bool = false
    let validator = LogInValidator()
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("TalkALot")
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
                            .border(isShowingError ? Color.red : Color.clear, width: 2)
                            
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        SecureField("Password", text: $password)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: geometry.size.width * 0.8)
                            .border(isShowingError ? Color.red : Color.clear, width: 2)
                        
                        Spacer()
                    }
                    .padding()
                    
                    Button(action: {
                        isShowingError = validator.validate(email: email, password: password)
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
                    
                    VStack{
                        if isShowingError {
                            Text("Invalid login information")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(height: 30) // Fixed height so spacing isn't affected
                    
                    Button(action:{
                        GoogleSignInHandler.shared.handleGoogleSignIn()
                    })
                    {
                        Image("GoogleLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        Text("Sign in with Google")
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

