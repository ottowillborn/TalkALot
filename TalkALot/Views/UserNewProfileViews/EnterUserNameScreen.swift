//
//  EnterUserNameScreen.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//
//add if username is taken
import SwiftUI
import FirebaseAuth

struct EnterUserNameScreen: View {
    @State private var username: String = ""

    var body: some View {
        VStack {
            Spacer()
            Text("Enter a Username")
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
                    .background(Color.blue)
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
        updateDisplayName(newDisplayName: username)
    }
}

func updateDisplayName(newDisplayName: String) {
    if let user = Auth.auth().currentUser {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        
        // Commit the changes
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Display name updated to: \(newDisplayName)")
            }
        }
    } else {
        print("No user is currently signed in.")
    }
}




struct EnterUserNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        EnterUserNameScreen()
    }
}
