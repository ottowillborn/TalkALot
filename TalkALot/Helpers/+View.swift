//
//  +View.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import Foundation

import SwiftUI

// Given a function to perform on confirmation, shows a popup to confirm deletion
struct DeleteConfirmationModifier: ViewModifier {
    @Binding var showAlert: Bool
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Yap"),
                    message: Text("Are you sure you want to delete this Yap?"),
                    primaryButton: .destructive(Text("Delete")) {
                        onDelete()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

extension View {
    func deleteConfirmation(showAlert: Binding<Bool>, onDelete: @escaping () -> Void) -> some View {
        self.modifier(DeleteConfirmationModifier(showAlert: showAlert, onDelete: onDelete))
    }
}

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


extension View {
    func defaultTextColor() -> some View {
        self.foregroundColor(AppColors.textPrimary)
    }
}

struct TapOutsideDetector: UIViewRepresentable {
    var onTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject {
        var onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func handleTap() {
            onTap()
        }
    }
}


struct TabBarAppearanceModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Customize the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(AppColors.background)
        
        // Adjust icon positioning
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textPrimary)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.highlightPrimary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ToolBarAppearanceModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(AppColors.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

//Loading animation module
class ViewController: UIViewController {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the activity indicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        // Start the loading animation
        activityIndicator.startAnimating()

        // Wait for 1 second and stop the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activityIndicator.stopAnimating()
            print("1 second has passed")
        }
    }
}
