//
//  ProfileView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-08.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct ProfileView: View {
    @Binding var showProfileMenuView: Bool // Binding to control visibility

    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main TabView with offset when profile view is shown
                NavigationView {
                    GeometryReader { geometry in
                        VStack {
                            //Profile content
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .navigationBarItems(
                            leading:
                                HStack{
                                    Button(action: {
                                        // Show profile view
                                        withAnimation {
                                            showProfileMenuView.toggle()
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
                                    Text("Profile")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading) // Align text to the left
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                        )
                        
                    }
                    .background(AppColors.background)
                    .defaultTextColor()
                }
                
            
       
        }
    }
}
