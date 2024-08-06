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
                                .shadow(color: .gray, radius: 10, x: 0, y: 10)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationTitle("Home")
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                RecordView()
            }
            .tabItem {
                Label("Record", systemImage: "mic")
            }
            
            Text("Another View")
                .tabItem {
                    Label("Other", systemImage: "star")
                }
        }
        .background(CustomTabBarModifier())
    }
}



struct CustomTabBarModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // Customize the tab bar appearance
        if let tabBar = viewController.tabBarController?.tabBar {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.stackedLayoutAppearance.normal.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
            
            // Adjust the tab bar height
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
            
            // Set a custom height
            if let tabBarItems = tabBar.items {
                tabBar.frame.size.height = 20 // Adjust height as needed
                for item in tabBarItems {
                    item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -10, right: 0) // Adjust if needed
                }
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}




struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
