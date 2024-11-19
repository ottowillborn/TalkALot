//
//  ProfileMenuView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-10.
//

import Foundation
import SwiftUI
import FirebaseAuth
struct ProfileMenuView: View {
    @Binding var showProfileMenuView: Bool // Binding to control visibility
    @EnvironmentObject var currentUserProfile: UserProfile


    
    var body: some View {
        ZStack {
            // conditional background to handle taps
            if showProfileMenuView {
                GeometryReader { geometry in
                    TapOutsideDetector {
                        withAnimation {
                            showProfileMenuView = false
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
                    .background(Color.clear) // Make sure it's transparent to not block taps
                }
            }
            VStack (alignment: .leading, spacing: 25) {
                Button(action: {
                    UserDefaults.standard.set("Profile", forKey: "selectedTab") //set user deafult tab to profile
                    showProfileMenuView.toggle() //toggle showProfileMenuView
                }) {
                    VStack {
                        if currentUserProfile.profileImage != nil {
                            Image(uiImage: currentUserProfile.profileImage!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                        }
                    }
                    
                    VStack (alignment: .leading) {
                        Text(Auth.auth().currentUser?.displayName ?? "Username")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("View Profile")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 5)
                    Spacer()
                }
                .padding(.top, 25)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(AppColors.textSecondary)
                HStack {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height:25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Settings")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                HStack {
                    Image(systemName: "bookmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Saved")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                HStack {
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Favourites")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                
                HStack {
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "signIn")
                        //Sign out of firebase
                        let firebaseAuth = Auth.auth()
                        do {
                          try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                          print("Error signing out: %@", signOutError)
                        }
                    }){
                        Image(systemName: "arrow.right.square")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height:25)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Sign Out")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, 5)
                    }
                }
                
                Spacer()
                
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.85, height:  UIScreen.main.bounds.height)
            .opacity(1) // Keep the background opacity at 1
            .background(AppColors.overlayBackground)
            .gesture(
                DragGesture(minimumDistance: 20) // Detect swipe gestures
                    .onEnded { value in
                        if value.translation.width < -50 { // Adjust swipe threshold if needed
                            withAnimation {
                                showProfileMenuView = false
                            }
                        }
                    }
            )
        }
    }
}
