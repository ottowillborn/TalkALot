//
//  AudioHelpers.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-04.
//

import AVFoundation

class AudioRecorder: ObservableObject {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var audioAmplitude: CGFloat = 0.0
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 48000,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: self.getURL(), settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startMonitoring()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { timer in
            if self.isRecording {
                self.audioRecorder?.updateMeters()
                let power = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                self.audioAmplitude = CGFloat(pow(10, power / 20))
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func getURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory.appendingPathComponent("recording.m4a")
    }
}

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var lowerValue: TimeInterval = 0
    @Published var upperValue: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var waveformData: [CGFloat] = [0]
    @Published var url: URL = URL(fileURLWithPath: "")

    
    private var timer: Timer?
    
    func startPlayback(url: URL) {
        do {
            // Configure the audio session, necessary for physical devices
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.delegate = self // Set the delegate
            self.seek(to: currentTime) // Start playback from slider
            audioPlayer?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("Failed to initialize playback: \(error.localizedDescription)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    func seekLowerValue(to time: TimeInterval) {
        lowerValue = time
    }
    
    func seekUpperValue(to time: TimeInterval) {
        upperValue = time
    }
    
    func initializePlayer(url: URL){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.delegate = self // Set the delegate
            self.seek(to: 0) // Start playback from slider
            lowerValue = 0
            upperValue = audioPlayer?.duration ?? 0
            waveformData = WaveformProcessor.generateWaveformData(for: url)
            self.url = url
        } catch {
            print("Failed to initialize playback: \(error.localizedDescription)")
        }
        
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Reset currentTime to 0 when playback finishes
        self.currentTime = 0
        self.isPlaying = false
        stopTimer()
    }
}

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
