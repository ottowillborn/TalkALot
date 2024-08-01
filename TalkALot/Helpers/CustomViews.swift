//
//  CustomViews.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-01.
//
import Foundation
import SwiftUI

//Takes a range and value (set, get)
struct CustomSlider: View {
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
