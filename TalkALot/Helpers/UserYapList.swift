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
    @Published var audioURLs: [URL] = []
    @Published var yaps: [Yap] = []
    
    init() {
        // Load initial data
        //fetchUserYaps()
    }
    
    func loadInitialData() {
        // Load audio URLs
        audioURLs = [
            Bundle.main.url(forResource: "sample1", withExtension: "m4a")!,
            Bundle.main.url(forResource: "sample3", withExtension: "m4a")!
        ]
        
        // Load Yap items
        yaps = [
            Yap(title: "Yap 1", url: Bundle.main.url(forResource: "sample1", withExtension: "m4a")!, date: Date()),
            Yap(title: "Bing Bong", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "afgan rabba 5", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "song", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "love this app", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "yeehaw", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "mook", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "mikayla is wonderful", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "she is my girlfriend", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "i love her so much", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
            Yap(title: "AWWWWWW", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: Date()),
        ]
    }
    
    func addYap(_ yap: Yap) {
        yaps.insert(yap, at: 0)
    }
    
    func removeYap(by id: UUID?) {
        guard let id = id else {
            // Handle the case where id is nil if needed
            return
        }
        if let index = yaps.firstIndex(where: { $0.id == id }) {
            yaps.remove(at: index)
        }
    }
    
    func fetchDraftYaps() {
        yaps = []
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Assuming you have the user's UUID
        let UUID = Auth.auth().currentUser?.uid ?? "defaultUserID"
        let yapsFolderRef = storageRef.child("\(UUID)/Yaps")

        // List all items in the Yaps folder
        yapsFolderRef.listAll { (result, error) in
            if let error = error {
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            // Unwrap result
            guard let result = result else {
                print("No items found in the Yaps folder.")
                return
            }
            
            // Iterate over each item in the folder
            for item in result.items {
                // Fetch metadata for each item
                item.getMetadata { metadata, error in
                    if let error = error {
                        print("Error fetching metadata for \(item.name): \(error.localizedDescription)")
                        return
                    }
                    
                    if let metadata = metadata {
                        // Retrieve custom metadata
                        let title = metadata.customMetadata?["title"] ?? "Unknown Title"
                        let dateString = metadata.customMetadata?["creationDate"] ?? "Unknown Date"
                        
                        // Convert date string to Date if necessary
                        let dateFormatter = DateFormatter()
                       // Set the expected format of the date string
                       dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Z represents the timezone offset (e.g., +0000)
                       dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // Set locale for consistent parsing

                       // Convert the string to a Date object
                       let date = dateFormatter.date(from: dateString)
                        
                        
                        //print("File Name: \(item.name)")
                        //print("Title: \(title)")
                        print("Date: \(dateString)")
                        
                        // Fetch the file's download URL
                        item.downloadURL { url, error in
                            if let error = error {
                                print("Error fetching download URL for \(item.name): \(error.localizedDescription)")
                                return
                            }
                            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(title).m4a")
                            
                            item.write(toFile: localURL) { url, error in
                                if let error = error {
                                    print("Error downloading file: \(error)")
                                    return
                                }
                                
                                if let url = url {
                                    print("Downloaded file to local URL: \(url)")
                                    
                                    // Use this `localURL` for your audio player
                                    let yap = Yap(title: title, url: localURL, date: date!)
                                    // Load yap into your audio player
                                    self.yaps.append(yap)
                                }
                            }
                        }
                        
                    }
                }
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
