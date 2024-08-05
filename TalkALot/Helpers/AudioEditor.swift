//
//  AudioEditor.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-04.
//

import AVFoundation

class AudioEditor {
    
    private var audioFile: AVAudioFile?
    
    init(fileURL: URL) throws {
        self.audioFile = try AVAudioFile(forReading: fileURL)
    }
    
    // trim the audio file so the selected section is retained and all else is removed
    func trimAudio(startTime: TimeInterval, endTime: TimeInterval, outputURL: URL) throws {
        guard let audioFile = audioFile else { return }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
                
        let format = audioFile.processingFormat
        
        let frameCount = AVAudioFrameCount((endTime - startTime) * audioFile.fileFormat.sampleRate)
        
        audioFile.framePosition = AVAudioFramePosition(startTime * audioFile.fileFormat.sampleRate)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        try audioFile.read(into: buffer, frameCount: frameCount)
        print( "read into")
        
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: settings)

        
        try outputFile.write(from: buffer)
    }
    
    // cut the audio file so the selected section is removed and all else is retained
    func cutAudio(startTime: TimeInterval, endTime: TimeInterval, outputURL: URL) throws {
        guard let audioFile = audioFile else { return }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        let format = audioFile.processingFormat
        let sampleRate = audioFile.fileFormat.sampleRate
        
        // Create a buffer for the portion before the cut
        let startFramePosition = AVAudioFramePosition(0)
        let startFrameCount = AVAudioFrameCount(startTime * sampleRate)
        let startBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: startFrameCount)!
        
        audioFile.framePosition = startFramePosition
        try audioFile.read(into: startBuffer, frameCount: startFrameCount)
        
        // Create a buffer for the portion after the cut
        let endFramePosition = AVAudioFramePosition(endTime * sampleRate)
        let remainingFrameCount = AVAudioFrameCount(audioFile.length - endFramePosition)
        let endBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: remainingFrameCount)!
        
        audioFile.framePosition = endFramePosition
        try audioFile.read(into: endBuffer, frameCount: remainingFrameCount)
        
        // Create the output file
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: settings)
        
        // Write the before and after buffers to the output file
        try outputFile.write(from: startBuffer)
        try outputFile.write(from: endBuffer)
    }
    
}
