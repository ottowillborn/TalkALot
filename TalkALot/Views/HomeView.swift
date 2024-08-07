//
//  HomeView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct HomeView: View {
    @State private var userEmail = Auth.auth().currentUser?.email
    @State private var showProfileView = false // State to track if the profile view is shown
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main TabView with offset when profile view is shown
            TabView {
                NavigationView {
                    GeometryReader { geometry in
                        VStack {
                            //Home content
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .navigationBarItems(
                            leading:
                                HStack{
                                    Button(action: {
                                        // Show profile view
                                        withAnimation {
                                            showProfileView.toggle()
                                        }
                                    }) {
                                        Circle()
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(AppColors.highlightPrimary)
                                            .overlay(
                                                Image(systemName: "person.crop.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(Color.gray)
                                            )
                                    }
                                    Text("Home")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading) // Align text to the left
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                        )
                        
                    }
                    .background(AppColors.background)
                    .defaultTextColor()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                NavigationView {
                    RecordView(showProfileView: $showProfileView)
                        .background(AppColors.background)
                        .defaultTextColor()
                }
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


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
