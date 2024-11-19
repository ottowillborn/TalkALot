//
//  Structs.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-11-18.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import SwiftUI

struct Yap: Identifiable {
    var id: UUID = UUID()
    
    var title: String
    //var likeCount: Int
    let url: URL
    var yapImage: UIImage
    let date: Date
}
