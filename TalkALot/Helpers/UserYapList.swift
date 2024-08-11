//
//  UserYapList.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-10.
//

import Foundation

class UserYapList: ObservableObject {
    @Published var audioURLs: [URL] = []
    @Published var yaps: [Yap] = []
    
    init() {
        // Load initial data
        loadInitialData()
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
}
