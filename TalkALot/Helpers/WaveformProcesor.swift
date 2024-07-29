//
//  WaveformProcesor.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//

import Foundation
import AVFoundation

class WaveformProcessor {
    static func generateWaveformData(for url: URL) -> [CGFloat] {
        var waveformData: [CGFloat] = []
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            print("Error loading audio file: \(error)")
            return []
        }

        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        
        if frameCount == 0 {
            print("Audio file is empty.")
            // Return default value, e.g., an array of zeros with a length of maxWaveformPoints
            let maxWaveformPoints = 100
            return Array(repeating: CGFloat(0), count: maxWaveformPoints)
        }

        do {
            try file.read(into: audioBuffer)
        } catch {
            print("Error reading audio buffer: \(error)")
            return []
        }

        guard let channelData = audioBuffer.floatChannelData?[0] else {
            return []
        }
        
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(frameCount)))
        
        let maxWaveformPoints = 100
        let samplesPerPoint = max(1, Int(frameCount) / maxWaveformPoints)

        for i in stride(from: 0, to: Int(frameCount), by: samplesPerPoint) {
            let samples = channelDataArray[i..<min(i + samplesPerPoint, Int(frameCount))]
            let maxAmplitude = samples.map { abs($0) }.max() ?? 0
            waveformData.append(CGFloat(maxAmplitude))
        }

        return waveformData
    }
}

