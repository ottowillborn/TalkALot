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
                    .navigationBarItems(leading:
                        Image("logo-no-background")
                            .resizable()                // Makes the image resizable
                            .aspectRatio(contentMode: .fit) // Maintains the aspect ratio
                            .frame(width: 150, height: 250) // Sets the frame size
                            .clipped()
                    )
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
        .background(TabBarAppearanceModifier())
    }
}





struct TabBarAppearanceModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Customize the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.black
        
        // Adjust icon positioning
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.blue
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}






struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
