//
//  PictureSelector.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.

//code includes fucntions allowing us to pic photos from local photogally to be uploaded.
//

import Foundation
import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage


struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }

    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

func uploadProfileImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
    
    let storageRef = Storage.storage().reference()
    let profileImageRef = storageRef.child("profilePictures/\(Auth.auth().currentUser?.uid ?? "defaultUserID").jpg")
    
    profileImageRef.putData(imageData, metadata: nil) { metadata, error in
        if let error = error {
            print("Error uploading profile image: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        profileImageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting download URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(url)
        }
    }
}

func updateProfilePicture(with url: URL) {
    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
    changeRequest?.photoURL = url
    
    changeRequest?.commitChanges { error in
        if let error = error {
            print("Error updating profile picture: \(error.localizedDescription)")
        } else {
            print("Profile picture updated successfully")
        }
    }
}

//called without parameter returns the current user profile, given a uid will return that users profile picture
func fetchProfilePicture(fetchFromUID: String = Auth.auth().currentUser?.uid ?? "defaultUID", completion: @escaping (UIImage?) -> Void) {
    let storage = Storage.storage()
    let profilePictureRef = storage.reference().child("profilePictures/\(fetchFromUID).jpg")
    
    // Download the image data
    profilePictureRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error fetching profile picture for UID \(fetchFromUID): \(error.localizedDescription)")
            completion(nil)
            return
        }
        //on completion return the image
        if let data = data, let image = UIImage(data: data) {
            completion(image)
        } else {
            print("Failed to decode image data for UID \(fetchFromUID).")
            completion(nil)
        }
    }
}

func fetchYapImage(photoURL: URL, completion: @escaping (UIImage?) -> Void) {
    // Download the image data from the URL
    URLSession.shared.dataTask(with: photoURL) { data, response, error in
        if let error = error {
            print("Error fetching profile picture: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        if let data = data, let image = UIImage(data: data) {
            completion(image)
        } else {
            completion(nil)
        }
    }.resume()
    
}

