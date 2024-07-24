//
//  +View.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import Foundation

import SwiftUI

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        
        return root
    }
}
