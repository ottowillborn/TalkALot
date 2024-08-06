//
//  AudioPlayerView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//
/*
 view for displaying, palying, and editing audio files
 */

import SwiftUI
import UIKit
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Binding var waveformData: [CGFloat]
    var audioURL: URL
    var isEditing: Bool = false
    @State var yapName = ""
    @State var isEditingTitle: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                if isEditing {
                    HStack {
                        if isEditingTitle {
                            TextField("Enter Yap Title", text: $yapName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 30, weight: .bold, design: .rounded))

                        } else {
                            Text(yapName)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.leading) // Align text to the left
                        }
                        
                        Button(action: {
                            if !yapName.isEmpty {
                                isEditingTitle.toggle()
                            }
                        }) {
                            Image(systemName: isEditingTitle ? "checkmark" : "pencil")
                                .foregroundStyle(.primary)
                                .font(.system(size: 25)) // Set the size of the icon
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    .padding()
                    
                }
                Spacer()
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
                    Button(action: {
                        // Cut audio in editor and store new file in existing URL's place, replacing it
                        editAudio(operation: .cut)
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
                    
                    Button(action: {
                        editAudio(operation: AudioEditOperation.trim)
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
                Spacer()
            }
            .onAppear{
                audioPlayer.initializePlayer(url: self.audioURL)
            }
            .padding(.horizontal)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
    
    private func editAudio(operation: AudioEditOperation) {
        do {
            let audioEditor = try AudioEditor(fileURL: audioURL)
            switch operation {
            case .trim: // replace trimmed audio in audioURL
                try audioEditor.trimAudio(startTime: audioPlayer.lowerValue, endTime: audioPlayer.upperValue, outputURL: audioURL)
            case .cut: // replace cut audio in audioURL
                try audioEditor.cutAudio(startTime: audioPlayer.lowerValue, endTime: audioPlayer.upperValue, outputURL: audioURL)
            }
            // re-initialize audio player as file has changed
            self.audioPlayer.initializePlayer(url: audioURL)
            // regenerate waveform as audio has changed
            self.waveformData = WaveformProcessor.generateWaveformData(for: audioURL)
        } catch {
            print("Failed to edit audio: \(error.localizedDescription)")
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
        self.upperValue = 180
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



