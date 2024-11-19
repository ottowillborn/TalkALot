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
    //var yapImage: UIImage
    var title: String
    //var likeCount: Int
    let url: URL
    let date: Date
}
