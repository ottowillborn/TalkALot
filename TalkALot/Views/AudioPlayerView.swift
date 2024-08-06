//
//  AudioPlayerView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//
/*
 Description:
 This file defines a SwiftUI view for an audio player interface. The AudioPlayerView
 allows users to play, pause, and seek audio playback.
 
 Responsibilities:
 - Display play/pause button to control audio playback
 - Display a slider to seek through the audio track
 - Display the current playback time
 
 Key Components:
 - AudioPlayer: An observed object managing audio playback state and controls
 - audioURL: The URL of the audio file to be played
 
 Key Methods:
 - body: Constructs the view hierarchy for the audio player interface
 - formatTime(_:): Converts a TimeInterval into a string formatted as MM:SS
 
 Dependencies:
 - SwiftUI
 - AudioPlayer (a custom ObservableObject managing audio playback)
 */

import SwiftUI
import UIKit
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Binding var waveformData: [CGFloat]
    var audioURL: URL
    var isEditing: Bool = false
    @State var toggleCutAudio = false
    @State var toggleTrimAudio = false
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                // Layer waveform ontop of audio slider
                ZStack{
                    WaveformView(data: waveformData)
                    PlaybackSlider(
                        value: Binding(
                            get: {
                                self.audioPlayer.currentTime
                            },
                            set: { (newValue) in
                                self.audioPlayer.seek(to: newValue)
                            }
                        ),
                        range: 0...self.audioPlayer.duration,
                        step: 0.01,
                        thumbSize: 300
                    )
                    // if editing, add the edit select tabs as an overlay
                    if isEditing {
                        EditCutSliders(
                            lowerValue: Binding(
                                get: { self.audioPlayer.lowerValue },
                                set: { newValue in self.audioPlayer.seekLowerValue(to: newValue) }
                            ),
                            upperValue: Binding(
                                get: {self.audioPlayer.upperValue},
                                set: {newValue in self.audioPlayer.seekUpperValue(to: newValue)}
                            ),
                            range: 0.0...self.audioPlayer.duration,
                            step: 0.01,
                            thumbSize: 300
                        )
                    }
                    
                }
                .frame(height: 300)
                
                    
                VStack{
                    Text(formatTime(self.audioPlayer.currentTime))
                        .frame(width: 50, alignment: .trailing)
                }
                
                HStack {
                    // Confirm cut button
                    Button(action: {
                        do {
                            // Cut audio in editor and store new file in existing URL's place, replacing it
                            // TODO: undo option for cuts
                            let audioEditor = try AudioEditor(fileURL: audioURL)
                            try audioEditor.cutAudio(startTime: audioPlayer.lowerValue, endTime: audioPlayer.upperValue, outputURL: audioURL)
                            self.audioPlayer.initializePlayer(url: audioURL) // re-initialize audio player as file has changed
                            self.waveformData = WaveformProcessor.generateWaveformData(for: audioURL) // regenerate waveform as audio has changed
                            self.toggleCutAudio = false // reset toggle cut
                        } catch {
                            print("Failed to cut audio: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Cut")
                    }
                    .frame(width:60, height: 30)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(isEditing ? 1 : 0) // Show or hide the button
                    .disabled(isEditing ? false : true) // Disable interaction when editing
                    .padding()
                    
                    
                    
                    // Skip backwards button
                    Button(action: {
                        // Action to skip backwards
                        let skipInterval: TimeInterval = -5
                        let newTime = max(self.audioPlayer.currentTime + skipInterval, 0)
                        self.audioPlayer.seek(to: newTime)
                    }) {
                        Image(systemName: "gobackward.5")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .opacity(isEditing ? 0 : 1) // Show or hide the button
                    .disabled(isEditing ? true : false) // Disable interaction when editing
                    .foregroundStyle(.blue)

                    
                    
                    // Play/Pause button
                    Button(action: {
                        if self.audioPlayer.isPlaying {
                            self.audioPlayer.pausePlayback()
                        } else {
                            self.audioPlayer.startPlayback(url: audioURL)
                        }
                    }) {
                        Image(systemName: self.audioPlayer.isPlaying && self.audioPlayer.currentTime != 0.0 ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                        
                    }
                    .padding()
                    
                    
                    // Skip forwards button
                    Button(action: {
                        // Action to skip forwards
                        let skipInterval: TimeInterval = 5
                        let newTime = min(self.audioPlayer.currentTime + skipInterval, self.audioPlayer.duration)
                        self.audioPlayer.seek(to: newTime)
                    }) {
                        Image(systemName: "goforward.5")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .opacity(isEditing ? 0 : 1) // Show or hide the button
                    .disabled(isEditing ? true : false) // Disable interaction when editing
                    .foregroundStyle(.blue)
                    
                    // Confirm trim button
                    Button(action: {
                        do {
                            // Trim audio in editor and store new file in existing URL's place, replacing it
                            // TODO: undo option for trims
                            let audioEditor = try AudioEditor(fileURL: audioURL)
                            try audioEditor.trimAudio(startTime: audioPlayer.lowerValue, endTime: audioPlayer.upperValue, outputURL: audioURL)
                            self.audioPlayer.initializePlayer(url: audioURL) // re-initialize audio player as file has changed
                            self.waveformData = WaveformProcessor.generateWaveformData(for: audioURL) // regenerate waveform as audio has changed
                            self.toggleTrimAudio = false // reset toggle trim
                        } catch {
                            print("Failed to trim audio: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Trim")
                    }
                    .frame(width:60, height: 30)
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(isEditing ? 1 : 0) // Show or hide the button
                    .disabled(isEditing ? false : true) // Disable interaction when editing
                    .padding()
                    
                    
                }
                .frame(height: 50)
                
            }
            .onAppear{
                audioPlayer.initializePlayer(url: self.audioURL)
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
    
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}




class MockAudioPlayer: AudioPlayer {
    override init() {
        super.init()
        self.duration = 180 // Mock duration of 3 minutes
        self.currentTime = 30 // Mock current time of 30 seconds
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock waveform data
        let mockWaveformData: [CGFloat] = Array(repeating: 0.02, count: 100)
        
        // Mock audio URL
        let mockURL = URL(string: "https://example.com/audiofile.mp3")!
        
        AudioPlayerView(
            audioPlayer: MockAudioPlayer(),
            waveformData: .constant(mockWaveformData),
            audioURL: mockURL,
            isEditing: (true) // Set to true to show editing view
        )
    }
}



