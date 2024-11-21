//
//  EnterProfilePictureView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI
import FirebaseAuth

struct EnterProfilePictureView: View {
    @State private var profileImage: UIImage?
    @State private var isImagePickerPresented = false
    @EnvironmentObject var currentUserProfile: UserProfile
    var email: String
    var password: String
    @Binding var name: String
    @Binding var birthdate: Date
    @Binding var username: String


    var body: some View {
        VStack {
            Spacer()
            Text("Upload a profile picture")
                .font(.title)
                .padding()

            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } else {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
            }
            
            NavigationLink(destination: FinalView().onAppear(perform: saveProfilePicture)) {
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
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $profileImage)
        }
    }

    //Function ending the sign up flow
    func saveProfilePicture() {
        // Create a DateFormatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Choose a date style
        formatter.timeStyle = .short // Choose a time style
        // Convert the Date object to a string
        let formattedDate = formatter.string(from: birthdate)
        currentUserProfile.name = self.name
        currentUserProfile.birthdate = formattedDate
        currentUserProfile.username = self.username
        currentUserProfile.profileImage = profileImage
        
        print(name)
        print(username)
        print(formattedDate)
        //Proceed with further actions (e.g., sign up the user)
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard error == nil else {
                print("Error during account creation: \(error!.localizedDescription)")
                return
            }
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard error == nil else {
                    print("Error during login: \(error!.localizedDescription)")
                    return
                }
                //If firebase authenticates, upload fresh profile and sign in
                currentUserProfile.uploadProfile()
                print("Current user: \(Auth.auth().currentUser?.uid ?? "No user")")
                print("USer:")
                print(currentUserProfile.currentUUID)
                updateDisplayName(to: currentUserProfile.username) { error in
                    if let error = error {
                        print("Failed to update display name:", error)
                    }
                }
                uploadProfileImage(currentUserProfile.profileImage ?? UIImage()) { url in
                       if let url = url {
                           updateProfilePicture(with: url)
                       }
                   }
                UserDefaults.standard.set(true, forKey: "signIn")

            }
        }
       
        
    }
}

struct FinalView: View {
    var body: some View {
        Text("This is the final screen")
            .font(.largeTitle)
            .padding()
    }
}

//struct EnterProfilePictureView_Previews: PreviewProvider {
//    static var previews: some View {
//        //EnterProfilePictureView()
//    }
//}
