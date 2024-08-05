//
//  CustomViews.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-01.
//
import Foundation
import SwiftUI

//Takes a range and value (set, get)
struct PlaybackSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let thumbSize: CGFloat = 35
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
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 2, height: thumbSize) // Set a narrow width and adjust height
                    .shadow(radius: 2)
                    .offset(x: sliderWidth - 11) // Offset by half of thumbs width plus half of grabbable frame
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = Double(gesture.location.x / totalWidth) * (range.upperBound - range.lowerBound) + range.lowerBound
                                value = min(max(range.lowerBound, newValue), range.upperBound)
                            }
                    )
                    .frame(width: 20)
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
    let thumbSize: CGFloat = 35
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
                    .frame(width: upperThumbPosition - lowerThumbPosition, height: 50)
                    .offset(x: lowerThumbPosition)
                    .opacity(0.5)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 2, height: thumbSize)
                        .shadow(radius: 2)
                    
                    Circle()
                        .frame(width: 15, height: thumbSize)
                        .foregroundColor(.red)
                        .offset(y: -thumbSize)
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
                        .foregroundColor(.red)
                        .offset(y: -thumbSize)
                    
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
