//
//  EnterUserNameScreen.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI

struct EnterUserNameScreen: View {
    @State private var username: String = ""

    var body: some View {
        VStack {
            Text("Enter a username")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: 300)
            
            NavigationLink(destination: EnterProfilePictureView().onAppear(perform: saveUsername)) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }

    func saveUsername() {
        UserDefaults.standard.set(username, forKey: "username")
    }
}



#Preview {
    EnterUserNameScreen()
}
