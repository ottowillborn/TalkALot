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
                guard let first = data.first else { return }
                let width = geometry.size.width
                let height = CGFloat(50)
                let step = width / CGFloat(data.count)

                path.move(to: CGPoint(x: 0, y: height / 2))
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * step
                    let y = (height / 2 - value * height / 2)
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: width, y: height / 2))
            }
            .stroke(Color.blue, lineWidth: 2)
            .frame(height: 100)
        }
    }
}

