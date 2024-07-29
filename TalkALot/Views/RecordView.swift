//
//  RecordView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//
/*
  Description:
  This file defines a SwiftUI view for recording and playing back audio. The RecordView
  provides an interface for users to start/stop recording and play the recorded audio.

  Responsibilities:
  - Display UI to start/stop audio recording
  - Show a button to control recording state
  - Integrate an audio player to play back the recorded audio

  Key Components:
  - AudioRecorder: An observed object managing audio recording
  - AudioPlayer: An observed object managing audio playback
  - hasRecording: A state variable indicating whether a recording exists

  Key Methods:
  - body: Constructs the view hierarchy for the recording interface
  - Button(action:): Toggles the recording state of the audio recorder

  Dependencies:
  - SwiftUI
  - FirebaseAuth
  - Firebase
  - AudioRecorder (a custom ObservableObject managing audio recording)
  - AudioPlayer (a custom ObservableObject managing audio playback)
  - AudioPlayerView (a custom SwiftUI view for audio playback)

*/

import SwiftUI
import FirebaseAuth
import Firebase

struct RecordView: View {
    @ObservedObject var audioRecorder = AudioRecorder()
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var hasRecording = false
    @State private var waveformData: [CGFloat] = [0]
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                
                VStack {
                    if !audioRecorder.isRecording {
                        if !hasRecording {
                            Text("Click to start recording")
                        } else {
                            Text("Click to re-record")
                        }
                    } else {
                        Text("Click to stop recording")
                    }
                    
                    Button(action: {
                        if !audioRecorder.isRecording {
                            self.audioRecorder.startRecording()
                        } else {
                            self.audioRecorder.stopRecording()
                            self.loadWaveformData()
                            hasRecording = true
                        }
                        
                    }) {
                        Circle()
                            .fill(audioRecorder.isRecording ? Color.red : Color.gray)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 100, height: 100)
                            )
                            .overlay(
                                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                    }
                    
                    if hasRecording {
                        AudioPlayerView(
                            audioPlayer: audioPlayer,
                            audioURL: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""),
                            waveformData: self.$waveformData)
                            .opacity(audioRecorder.isRecording || !hasRecording ? 0 : 0.8)
                    }
                    
                    
                    
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    private func loadWaveformData() {
        // Use WaveformProcessor to generate waveform data
        self.waveformData = WaveformProcessor.generateWaveformData(for: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""))
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}