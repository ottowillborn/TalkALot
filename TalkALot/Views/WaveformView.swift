//
//  WaveformView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//

import SwiftUI

struct WaveformView: View {
    var data: [CGFloat]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height: CGFloat = 300 // Frame height
                let step = width / CGFloat(data.count)
                
                // Move to the starting point (left edge)
                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * step
                    let y = value * height * 3 // Calculate the y position for the waveform

                    // Calculate the positions while clamping them within bounds
                    let upperY = height / 2 - min(max(y, 0), height / 2)
                    let lowerY = height / 2 + min(max(y, 0), height / 2)

                    // Draw the line above the center
                    path.addLine(to: CGPoint(x: x, y: upperY))
                    
                    // Draw the line below the center
                    path.addLine(to: CGPoint(x: x, y: lowerY))
                }

                // Connect back to the center line on the right edge
                path.addLine(to: CGPoint(x: width, y: height / 2))
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}



