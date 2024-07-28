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
    var audioPlayer: AVAudioPlayer?
    var recordingSession: AVAudioSession
    @Published var isRecording = false
    
    init() {
        self.recordingSession = AVAudioSession.sharedInstance()
        setupRecording()
    }
    
    func setupRecording() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        // Handle permission not granted
                        print("Permission to access the microphone was not granted.")
                    }
                }
            }
        } catch {
            // Handle setup error
            print("Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            print("Recording started. File saved at: \(audioFilename)")
        } catch {
            // Handle recording error
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped.")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


