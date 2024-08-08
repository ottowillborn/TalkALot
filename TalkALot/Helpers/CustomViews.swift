//
//  CustomViews.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-01.
//
import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct EditTextView: View {
    @Binding var showEditTextView: Bool // Binding to control visibility
    @FocusState private var isTextFieldFocused: Bool // Focus state for the TextField
    
    var body: some View {
        ZStack {
            // Conditional background to handle taps
            if showEditTextView {
                GeometryReader { geometry in
                    TapOutsideDetector {
                        withAnimation {
                            showEditTextView = false
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .background(Color.clear) // Make sure it's transparent to not block taps
                }
            }
            
            VStack(alignment: .leading, spacing: 25) {
                // Your content here
                TextField("Enter text...", text: .constant(""))
                    .focused($isTextFieldFocused)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
            .opacity(1) // Keep the background opacity at 1
            .background(AppColors.overlayBackground)
            .gesture(
                DragGesture(minimumDistance: 20) // Detect swipe gestures
                    .onEnded { value in
                        if value.translation.height > 50 { // Adjust swipe threshold if needed
                            withAnimation {
                                showEditTextView = false
                            }
                        }
                    }
            )
            .onChange(of: showEditTextView) { newValue in
                // Trigger keyboard based on visibility
                isTextFieldFocused = newValue
            }
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: Color
    var textColor: Color

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 10) // Adjust padding to align with TextField
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .opacity(0.5)
            }
            TextField("", text: $text)
                .foregroundColor(textColor)
                .background(Color.clear)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.textSecondary, lineWidth: 2) // Border with rounded corners
                        .opacity(0.5)
                )
                .font(.system(size: 30, weight: .bold, design: .rounded))
        }
    }
}

struct ProfileView: View {
    @Binding var showProfileView: Bool // Binding to control visibility
    
    var body: some View {
        ZStack {
            // conditional background to handle taps
            if showProfileView {
                GeometryReader { geometry in
                    TapOutsideDetector {
                        withAnimation {
                            showProfileView = false
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
                    .background(Color.clear) // Make sure it's transparent to not block taps
                }
            }
            VStack (alignment: .leading, spacing: 25) {
                Button(action: {
                    
                }) {
                    Circle()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(AppColors.highlightPrimary)
                        .overlay(
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color.gray)
                        )
                    VStack (alignment: .leading) {
                        Text(Auth.auth().currentUser?.displayName ?? "Username")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("View Profile")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 5)
                    Spacer()
                }
                .padding(.top, 25)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(AppColors.textSecondary)
                HStack {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height:25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Settings")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                HStack {
                    Image(systemName: "bookmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Saved")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                HStack {
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Favourites")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 5)
                }
                
                HStack {
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "signIn")
                    }){
                        Image(systemName: "arrow.right.square")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height:25)
                            .foregroundColor(AppColors.textPrimary)
                        Text("Sign Out")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, 5)
                    }
                }
                
                Spacer()
                
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.85, height:  UIScreen.main.bounds.height)
            .opacity(1) // Keep the background opacity at 1
            .background(AppColors.overlayBackground)
            .gesture(
                DragGesture(minimumDistance: 20) // Detect swipe gestures
                    .onEnded { value in
                        if value.translation.width < -50 { // Adjust swipe threshold if needed
                            withAnimation {
                                showProfileView = false
                            }
                        }
                    }
            )
        }
    }
}

//Takes a range and value (set, get)
struct PlaybackSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var thumbSize: CGFloat = 35
    let trackHeight: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let sliderWidth = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * totalWidth
            
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .foregroundColor(Color.blue.opacity(0.5))
                    .frame(height: trackHeight)
                
                // Thumb
                ZStack{
                    Rectangle()
                        .foregroundColor(AppColors.highlightPrimary)
                        .frame(width: 2, height: thumbSize) // Set a narrow width and adjust height
                        .shadow(radius: 2)
                        .frame(width: 20)
                    Rectangle()
                        .foregroundColor(AppColors.highlightPrimary)
                        .frame(width: 40, height: 15) // Set a narrow width and adjust height
                        .shadow(radius: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .offset(y:thumbSize/2)
                }
                .offset(x: sliderWidth - 20) // Offset by half of thumbs width plus half of grabbable frame
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newValue = Double(gesture.location.x / totalWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                            value = min(max(range.lowerBound, newValue), range.upperBound)
                        }
                )
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }
}

// Sliders to select desired time range when editing
struct EditCutSliders: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let range: ClosedRange<Double>
    let step: Double
    var thumbSize: CGFloat = 300
    let trackHeight: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let lowerThumbPosition = CGFloat((lowerValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * totalWidth
            let upperThumbPosition = CGFloat((upperValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * totalWidth
            
            ZStack(alignment: .leading) {
                
                // Selected range track
                Rectangle()
                    .foregroundColor(Color.gray)
                    .frame(width: upperThumbPosition - lowerThumbPosition, height: thumbSize)
                    .offset(x: lowerThumbPosition)
                    .opacity(0.15)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 2, height: thumbSize)
                        .shadow(radius: 2)
                    
                    Circle()
                        .frame(width: 15, height: thumbSize)
                        .foregroundColor(AppColors.highlightPrimary)
                        .offset(y: -thumbSize/2)
                }
                .offset(x: lowerThumbPosition - 8)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newValue = Double(gesture.location.x / totalWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                            lowerValue = min(max(range.lowerBound, newValue), upperValue)
                        }
                )
                
                // Upper Thumb
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 2, height: thumbSize)
                        .shadow(radius: 2)
                    
                    Circle()
                        .frame(width: 15, height: thumbSize)
                        .foregroundColor(AppColors.highlightPrimary)
                        .offset(y: -thumbSize/2)
                    
                }
                .offset(x: upperThumbPosition - 8)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newValue = Double(gesture.location.x / totalWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                            upperValue = max(min(range.upperBound, newValue), lowerValue)
                        }
                )
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }
}
