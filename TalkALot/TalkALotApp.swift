//
//  SignInUsingGoogle.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI

@main
struct TalkALotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("signIn") var isSignIn = false
    @AppStorage("selectedTab") private var selectedTab: String = "Home"
    @StateObject private var currentUserYaps = UserYapList()


    @State private var showProfileMenuView = false // State to track if the profile view is shown

    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .leading) {

            if !isSignIn {
                LoginView()
            } else {
                TabView (selection: $selectedTab) {
                    HomeView(showProfileMenuView: $showProfileMenuView)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag("Home")
                    
                    RecordView(showProfileMenuView: $showProfileMenuView)
                        .environmentObject(currentUserYaps)
                        .background(AppColors.background)
                        .defaultTextColor()
                        .tabItem {
                            Label("Record", systemImage: "mic")
                        }
                        .tag("Record")
                    
                    ProfileView(showProfileMenuView: $showProfileMenuView)
                        .environmentObject(currentUserYaps)
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag("Profile")
                }
                .opacity(showProfileMenuView ? 0.3 : 1)
                .background(AppColors.background)
                .background(TabBarAppearanceModifier())
                .background(ToolBarAppearanceModifier())
                .offset(x: showProfileMenuView ? UIScreen.main.bounds.width * 0.85 : 0) // Offset when profile view is shown
                .animation(.linear(duration: 0.2), value: showProfileMenuView)
                
                // Profile view sliding in from the left
                ProfileMenuView(showProfileMenuView: $showProfileMenuView)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .offset(x: showProfileMenuView ? 0 : -UIScreen.main.bounds.width * 0.85)
                    .opacity(1)
                    .animation(.linear(duration: 0.2), value: showProfileMenuView)
                
                
            }
        }
    }
    }
}



