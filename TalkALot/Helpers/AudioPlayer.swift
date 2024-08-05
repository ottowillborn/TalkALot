//
//  AudioPlayer.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//
/*
  Description:
  This file defines a class for managing audio playback functionalities. The AudioPlayer
  class allows users to play, pause, and stop audio playback, as well as seek to specific
  positions within the audio track.

  Responsibilities:
  - Manage audio playback using AVAudioPlayer
  - Provide controls to start, pause, stop, and seek audio playback
  - Update and publish playback state and timing information

  Key Components:
  - audioPlayer: An instance of AVAudioPlayer for playing audio
  - isPlaying: A published property indicating whether audio is currently playing
  - currentTime: A published property tracking the current playback time
  - duration: A published property representing the duration of the audio track
  - timer: A timer to update currentTime periodically

  Key Methods:
  - startPlayback(url:): Starts audio playback from the given URL
  - pausePlayback(): Pauses the current audio playback
  - stopPlayback(): Stops the current audio playback and resets the current time
  - seek(to:): Seeks to a specific time within the audio track
  - startTimer(): Starts a timer to update the current time during playback
  - stopTimer(): Stops the timer
  - audioPlayerDidFinishPlaying(_:successfully:): Resets the current time and playback state when playback finishes

  Dependencies:
  - Foundation
  - AVFoundation
*/
 
import Foundation
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var lowerValue: TimeInterval = 0
    @Published var upperValue: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
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
            self.seek(to: currentTime) // Start playback from slider
            lowerValue = 0
            upperValue = audioPlayer?.duration ?? 0
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


