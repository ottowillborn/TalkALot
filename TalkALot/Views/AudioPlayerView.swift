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
    
    var body: some View {
        VStack {
            
            HStack {
                Button(action: {
                    if self.audioPlayer.isPlaying {
                        self.audioPlayer.pausePlayback()
                    } else {
                        self.audioPlayer.startPlayback(url: self.audioURL)
                    }
                }) {
                    Image(systemName: self.audioPlayer.isPlaying && self.audioPlayer.currentTime != 0.0 ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                // Layer waveform ontop of audio slider
                ZStack{
                    WaveformView(data: waveformData)
                    CustomSlider(value: Binding(
                        get: {
                            self.audioPlayer.currentTime
                        },
                        set: { (newValue) in
                            self.audioPlayer.seek(to: newValue)
                        }
                    ), range: 0...self.audioPlayer.duration, step: 0.01)
                    .frame(height: 50)
                    
                }
                .frame(height: 100)
                
                Text(formatTime(self.audioPlayer.currentTime))
                    .frame(width: 60, alignment: .trailing)
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}




//struct AudioPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        let audioPlayer = AudioPlayer()
//        return AudioPlayerView(audioPlayer: audioPlayer, audioURL: URL(fileURLWithPath: ""), waveformData: waveformData)
//    }
//}



