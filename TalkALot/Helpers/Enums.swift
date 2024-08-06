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

enum AppColors {
    static let backgroundColor = Color.white // #FFFFFF
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
    static let lightGray = Color(red: 0.94, green: 0.94, blue: 0.96) // #F0F0F5
    static let mediumGray = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    static let darkGray = Color(red: 0.33, green: 0.33, blue: 0.33) // #555555
    static let textColor = Color.black // #000000
    static let secondaryTextColor = Color(red: 0.33, green: 0.33, blue: 0.33) // #555555
    static let disabledColor = Color(red: 0.78, green: 0.78, blue: 0.8) // #C7C7CC
}
