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

struct TabBarAppearanceModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Customize the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.black
        
        // Adjust icon positioning
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.blue
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
