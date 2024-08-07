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
    
    var body: some View {
        TabView {
            NavigationView {
                GeometryReader { geometry in
                    VStack {
                        Text("Welcome " + (userEmail ?? ""))
                        
                        Button(action: {
                            UserDefaults.standard.set(false, forKey: "signIn")
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200, height: 50)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(25)
                                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarItems(
                        leading:
                            HStack{
                                Button(action: {
                                    // TODO: add profile sub view
                                }) {
                                    Circle()
                                        .frame(width: 35, height: 35)
                                        .padding(.leading, -10)
                                        .foregroundStyle(AppColors.highlightPrimary)
                                        .overlay(
                                            Image(systemName: "person.crop.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(Color.gray)
                                                .padding(.leading,-10)
                                        )
                                }
                                Text("Home")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.leading) // Align text to the left
                                    .foregroundStyle(AppColors.textSecondary)
                                    .padding(.leading,-10)
                            }
                            .padding(.bottom,15)
                    )
                }
                .background(AppColors.background)
                .defaultTextColor()
                
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                RecordView()
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
        .background(TabBarAppearanceModifier())
        .background(ToolBarAppearanceModifier())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
