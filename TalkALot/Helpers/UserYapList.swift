//
//  UserYapList.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-10.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import SwiftUI


class UserYapList: ObservableObject {
    @Published var yaps: [Yap] = []
    
    init() {
        // Load initial data
        //fetchUserYaps()
    }
    
    func addYap(_ yap: Yap) {
        yaps.insert(yap, at: 0)
    }
    
    func removeYap(by id: UUID?) {
        let UUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        guard let id = id else {
            // Handle the case where id is nil if needed
            return
        }
        if let index = yaps.firstIndex(where: { $0.id == id }) {
            let removedTitle = yaps.remove(at: index).title
            
            // Get a reference to the storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // Reference to the file you want to delete
            let fileRef = storageRef.child("\(UUID)/Yaps/\(removedTitle)")
            
            // Delete the file
            fileRef.delete { error in
                if let error = error {
                    // Handle error
                    print("Error deleting file: \(error.localizedDescription)")
                } else {
                    // File deleted successfully
                    print("File deleted successfully")
                }
            }
        }
    }
    
    func shareYap(by id: UUID?){
        let currentUUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        guard let id = id else {
            // Handle the case where id is nil if needed
            return
        }
        if let index = yaps.firstIndex(where: { $0.id == id }) {
            let removedTitle = yaps.remove(at: index).title
            
            // Get a reference to the storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            // Reference to the original file location
            let originalFileRef = storageRef.child("\(currentUUID)/Yaps/\(removedTitle)")
            
            // Reference to the new location for the file (e.g., moving to another folder)
            let newFileRef = storageRef.child("PublicYaps/\(removedTitle)")
            
            // Download the file from the original location
            originalFileRef.getMetadata { metadata, error in
                if let error = error {
                    print("Error fetching metadata for \(originalFileRef.name): \(error.localizedDescription)")
                    return
                }
                
                guard let metadata = metadata else {
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                // Retrieve custom metadata
                let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                let date = dateFormatter.date(from: dateString)
                let publishingProfileUUID = currentUUID
                
                // Fetch download URL
                originalFileRef.downloadURL { url, error in
                    if let error = error {
                        print("Error fetching download URL for \(originalFileRef.name): \(error.localizedDescription)")
                        return
                    }
                    
                    // Download the file to a local URL
                    let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title).m4a")
                    originalFileRef.write(toFile: localURL) { url, error in
                        if let error = error {
                            print("Error downloading file: \(error)")
                            return
                        }
                    }
                    
                    // Upload the file to the new location
                    newFileRef.putFile(from: localURL, metadata: metadata) { metadata, error in
                        if let error = error {
                            print("Error uploading file to new location: \(error.localizedDescription)")
                            return
                        }
                        
                        // Create new metadata to update
                            let metadata = StorageMetadata()
                            metadata.customMetadata = [
                                "isDraft": "false",
                                "isShared": "true",
                                "postedBy": publishingProfileUUID
                                
                            ]
                        
                        // Update the file's metadata
                        newFileRef.updateMetadata(metadata) { (updatedMetadata, error) in
                               if let error = error {
                                   print("Error updating metadata: \(error.localizedDescription)")
                               } else if let updatedMetadata = updatedMetadata {
                                   print("Metadata updated successfully: \(updatedMetadata.customMetadata ?? [:])")
                               }
                           }
                        originalFileRef.updateMetadata(metadata) { (updatedMetadata, error) in
                               if let error = error {
                                   print("Error updating metadata: \(error.localizedDescription)")
                               } else if let updatedMetadata = updatedMetadata {
                                   print("Metadata updated successfully: \(updatedMetadata.customMetadata ?? [:])")
                               }
                           }
                    }
                }
                
            }
        }

    }
    
    func fetchDraftYaps() {
        yaps = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let UUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        let yapsFolderRef = storageRef.child("\(UUID)/Yaps")
        
        let dispatchGroup = DispatchGroup()  // Group to handle multiple async tasks
        
        // Reuse the dateFormatter to avoid creating a new one for each item
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        yapsFolderRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else {
                print("No items found in the Yaps folder.")
                return
            }
            
            // Iterate over items concurrently
            for item in result.items {
                dispatchGroup.enter() // Start a new task in the group
                
                // Fetch metadata
                item.getMetadata { metadata, error in
                    var yapImage: UIImage = UIImage()

                    if let error = error {
                        print("Error fetching metadata for \(item.name): \(error.localizedDescription)")
                        dispatchGroup.leave() // Leave the group if error occurs
                        return
                    }
                    
                    guard let metadata = metadata else {
                        dispatchGroup.leave() // Leave the group if no metadata
                        return
                    }
                    
                    // Retrieve custom metadata
                    let isDraft = metadata.customMetadata?["isDraft"] == "true" ? "true" : "false"
                    if isDraft == "true" {
                        let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                        let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                        let date = dateFormatter.date(from: dateString)
                        let imageURL = metadata.customMetadata?["imageURL"] ?? "Unknown imageURL"
                        let postedBy = metadata.customMetadata?["postedBy"] ?? "Unknown postedBy"
                        let creatorUsername = metadata.customMetadata?["creatorUsername"] ?? "Unknown creator"

                        fetchYapImage(photoURL: URL(string: imageURL)!) { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    yapImage = image
                                }
                            }
                        }
                        
                        // Fetch download URL
                        item.downloadURL { url, error in
                            if let error = error {
                                print("Error fetching download URL for \(item.name): \(error.localizedDescription)")
                                dispatchGroup.leave() // Leave the group if error occurs
                                return
                            }
                            
                            // Download the file to a local URL
                            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title).m4a")
                            item.write(toFile: localURL) { url, error in
                                if let error = error {
                                    print("Error downloading file: \(error)")
                                    dispatchGroup.leave() // Leave the group if error occurs
                                    return
                                }
                                
                                // Use the downloaded file and update the yap
                                if let url = url {
                                    //print("Downloaded file to local URL: \(url)")
                                    let yap = Yap(postedBy: postedBy,creatorUsername: creatorUsername, title: title, url: localURL, yapImage: yapImage, date: date ?? Date())
                                    self.yaps.append(yap)
                                }
                                
                                dispatchGroup.leave() // Leave the group after completing the download
                            }
                        }
                    }
                }
            }
            
            // Once all tasks are completed, perform final operations
            dispatchGroup.notify(queue: .main) {
                print("All Yaps fetched successfully")
                // You can now update UI or perform other tasks after all files are downloaded
            }
        }
    }

    func fetchLikedYaps(){
        yaps = []
    }
    
    //Fetch user specific shared yaps
    func fetchSharedYaps(){
        yaps = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let UUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        let yapsFolderRef = storageRef.child("\(UUID)/Yaps")
        
        let dispatchGroup = DispatchGroup()  // Group to handle multiple async tasks
        
        // Reuse the dateFormatter to avoid creating a new one for each item
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        yapsFolderRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else {
                print("No items found in the Yaps folder.")
                return
            }
            
            // Iterate over items concurrently
            for item in result.items {
                dispatchGroup.enter() // Start a new task in the group
                
                // Fetch metadata
                item.getMetadata { metadata, error in
                    var yapImage: UIImage = UIImage()

                    if let error = error {
                        print("Error fetching metadata for \(item.name): \(error.localizedDescription)")
                        dispatchGroup.leave() // Leave the group if error occurs
                        return
                    }
                    
                    guard let metadata = metadata else {
                        dispatchGroup.leave() // Leave the group if no metadata
                        return
                    }
                    
                    // Retrieve custom metadata
                    let isShared = metadata.customMetadata?["isShared"] == "true" ? "true" : "false"
                    if isShared == "true" {
                        let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                        let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                        let date = dateFormatter.date(from: dateString)
                        let imageURL = metadata.customMetadata?["imageURL"] ?? "Unknown imageURL"
                        let postedBy = metadata.customMetadata?["postedBy"] ?? "Unknown postedBy"
                        let creatorUsername = metadata.customMetadata?["creatorUsername"] ?? "Unknown creator"

                        fetchYapImage(photoURL: URL(string: imageURL)!) { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    yapImage = image
                                }
                            }
                        }
                        
                        // Fetch download URL
                        item.downloadURL { url, error in
                            if let error = error {
                                print("Error fetching download URL for \(item.name): \(error.localizedDescription)")
                                dispatchGroup.leave() // Leave the group if error occurs
                                return
                            }
                            
                            // Download the file to a local URL
                            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title).m4a")
                            item.write(toFile: localURL) { url, error in
                                if let error = error {
                                    print("Error downloading file: \(error)")
                                    dispatchGroup.leave() // Leave the group if error occurs
                                    return
                                }
                                
                                // Use the downloaded file and update the yap
                                if let url = url {
                                    //print("Downloaded file to local URL: \(url)")
                                    let yap = Yap(postedBy: postedBy,creatorUsername: creatorUsername, title: title, url: localURL, yapImage: yapImage, date: date ?? Date())
                                    self.yaps.append(yap)
                                }
                                
                                dispatchGroup.leave() // Leave the group after completing the download
                            }
                        }
                    }
                }
            }
            
            // Once all tasks are completed, perform final operations
            dispatchGroup.notify(queue: .main) {
                print("All Yaps fetched successfully")
                self.yaps.sort(by: { $0.date > $1.date })
            }
        }
    }
    
    func fetchPublicYaps(completion: @escaping () -> Void){
        yaps = []
        let storage = Storage.storage()
        let storageRef = storage.reference()
        //let UUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        let yapsFolderRef = storageRef.child("PublicYaps")
        
        let dispatchGroup = DispatchGroup()  // Group to handle multiple async tasks
        
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        yapsFolderRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else {
                print("No items found in the Yaps folder.")
                return
            }
            
            // Iterate over items concurrently
            for item in result.items {
                dispatchGroup.enter() // Start a new task in the group

                // Fetch metadata
                item.getMetadata { metadata, error in
                    if let error = error {
                        print("Error fetching metadata for \(item.name): \(error.localizedDescription)")
                        dispatchGroup.leave() // Leave the group if error occurs
                        return
                    }
                    
                    guard let metadata = metadata else {
                        dispatchGroup.leave() // Leave the group if no metadata
                        return
                    }

                    // Extract metadata
                    let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                    let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                    let date = dateFormatter.date(from: dateString)
                    let imageURL = metadata.customMetadata?["imageURL"] ?? ""
                    let postedBy = metadata.customMetadata?["postedBy"] ?? "Unknown postedBy"
                    let creatorUsername = metadata.customMetadata?["creatorUsername"] ?? "Unknown creator"


                    // Fetch the image
                    dispatchGroup.enter() // Account for the image fetch operation
                    fetchYapImage(photoURL: URL(string: imageURL)!) { image in
                        let yapImage = image ?? UIImage() // Use a default image if nil
                        
                        // Fetch download URL
                        item.downloadURL { url, error in
                            if let error = error {
                                print("Error fetching download URL for \(item.name): \(error.localizedDescription)")
                                dispatchGroup.leave() // Leave the group if error occurs
                                return
                            }

                            // Download the file to a local URL
                            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title).m4a")
                            item.write(toFile: localURL) { url, error in
                                if let error = error {
                                    print("Error downloading file: \(error)")
                                    dispatchGroup.leave() // Leave the group if error occurs
                                    return
                                }

                                // Use the downloaded file and update the yap
                                if url != nil {
                                    //print("Downloaded file to local URL: \(url)")
                                    let yap = Yap(postedBy: postedBy,creatorUsername: creatorUsername, title: title, url: localURL, yapImage: yapImage, date: date ?? Date())
                                    self.yaps.append(yap)
                                }
                                
                                dispatchGroup.leave() // Leave the group after completing the download
                            }
                        }
                        
                        dispatchGroup.leave() // Leave the group after fetching the image
                    }
                }
            }

            // Once all tasks are completed, perform final operations
            dispatchGroup.notify(queue: .main) {
                print("All Yaps fetched successfully")
                // Sort chronologically descending
                self.yaps.sort(by: { $0.date > $1.date })
                completion()
            }
            
        }
        
    }
}
