//
//  Enums.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-06.
//

import Foundation
import SwiftUI

enum AudioEditOperation {
    case trim
    case cut
}

struct AppColors {
    static let background = Color(red: 18/255, green: 18/255, blue: 18/255)
    static let surface = Color(red: 30/255, green: 30/255, blue: 30/255)
    static let textPrimary = Color(red: 224/255, green: 224/255, blue: 224/255)
    static let textSecondary = Color(red: 176/255, green: 176/255, blue: 176/255)
    
    // Highlight Colors
    static let highlightPrimary = Color(red: 200/255, green: 0/255, blue: 100/255)
    static let highlightSecondary = Color(red: 255/255, green: 77/255, blue: 166/255)
    static let accent = Color(red: 255/255, green: 91/255, blue: 137/255)
    
    // Supporting Colors
    static let success = Color(red: 0/255, green: 230/255, blue: 118/255)
    static let warning = Color(red: 255/255, green: 234/255, blue: 0/255)
    static let error = Color(red: 255/255, green: 23/255, blue: 68/255)
}
