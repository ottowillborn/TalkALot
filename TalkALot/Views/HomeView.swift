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
    @Binding var showProfileView: Bool // Binding to control visibility

    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main TabView with offset when profile view is shown
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
                
            
       
        }
    }
}


//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
