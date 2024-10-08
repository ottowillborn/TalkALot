//
//  EnterProfilePictureView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI

struct EnterProfilePictureView: View {
    @State private var profileImage: UIImage?
    @State private var isImagePickerPresented = false

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

    func saveProfilePicture() {
        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profilePicture")
        }
        UserDefaults.standard.set(true, forKey: "signIn")
    }
}

struct FinalView: View {
    var body: some View {
        Text("This is the final screen")
            .font(.largeTitle)
            .padding()
    }
}

struct EnterProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        EnterProfilePictureView()
    }
}
