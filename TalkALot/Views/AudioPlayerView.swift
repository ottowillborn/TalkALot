//
//  AudioPlayerView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
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
                
                Slider(value: Binding(
                    get: {
                        self.audioPlayer.currentTime
                    },
                    set: { (newValue) in
                        self.audioPlayer.seek(to: newValue)
                    }
                ), in: 0...self.audioPlayer.duration)
                .accentColor(.blue)
                
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

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let audioPlayer = AudioPlayer()
        return AudioPlayerView(audioPlayer: audioPlayer, audioURL: URL(fileURLWithPath: ""))
    }
}

