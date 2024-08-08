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
    @State private var showProfileView = false // State to track if the profile view is shown

    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .leading) {

            if !isSignIn {
                LoginView()
            } else {
                TabView {
                    HomeView(showProfileView: $showProfileView)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    RecordView(showProfileView: $showProfileView)
                        .background(AppColors.background)
                        .defaultTextColor()
                        .tabItem {
                        Label("Record", systemImage: "mic")
                    }
                    
                    Text("Another View")
                        .tabItem {
                            Label("Other", systemImage: "star")
                        }
                }
                .opacity(showProfileView ? 0.3 : 1)
                .background(AppColors.background)
                .background(TabBarAppearanceModifier())
                .background(ToolBarAppearanceModifier())
                .offset(x: showProfileView ? UIScreen.main.bounds.width * 0.85 : 0) // Offset when profile view is shown
                .animation(.linear(duration: 0.2), value: showProfileView)
                
                // Profile view sliding in from the left
                ProfileView(showProfileView: $showProfileView)
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .offset(x: showProfileView ? 0 : -UIScreen.main.bounds.width * 0.85)
                    .opacity(1)
                    .animation(.linear(duration: 0.2), value: showProfileView)
                
                
            }
        }
    }
    }
}



