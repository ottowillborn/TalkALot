//
//  AudioRecorder.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//
/*
  Description:
  This file defines a class for managing audio recording functionalities. The AudioRecorder
  class allows users to start and stop audio recordings, and handles the setup of the
  audio recording session.

  Responsibilities:
  - Manage audio recording session setup and permissions
  - Start and stop audio recordings
  - Save recorded audio files to the device's document directory

  Key Components:
  - audioRecorder: An instance of AVAudioRecorder for recording audio
  - audioPlayer: An instance of AVAudioPlayer for playing back audio (currently unused)
  - recordingSession: An instance of AVAudioSession for managing audio session settings
  - isRecording: A published property indicating whether recording is in progress

  Key Methods:
  - init(): Initializes the AudioRecorder and sets up the recording session
  - setupRecording(): Configures the audio session and requests microphone permissions
  - startRecording(): Starts recording audio and saves the file in the document directory
  - stopRecording(): Stops the current audio recording
  - getDocumentsDirectory(): Returns the URL of the document directory

  Dependencies:
  - Foundation
  - AVFoundation
*/

import Foundation
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



