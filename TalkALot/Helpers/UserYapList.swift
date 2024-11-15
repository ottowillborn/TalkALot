//
//  UserYapList.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-10.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

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
                    let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                    let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                    let date = dateFormatter.date(from: dateString)
                    
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
                                print("Downloaded file to local URL: \(url)")
                                let yap = Yap(title: title, url: localURL, date: date ?? Date())
                                self.yaps.append(yap)
                            }
                            
                            dispatchGroup.leave() // Leave the group after completing the download
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
    
    func fetchSharedYaps(){
        yaps = []
    }
}
