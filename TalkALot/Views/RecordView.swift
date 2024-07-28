//
//  RecordView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-28.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct RecordView: View {
    @ObservedObject var audioRecorder = AudioRecorder()
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var hasRecording = false
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                
                VStack {
                    //if not recording, button is grey mic, self.audioRecorder.startRecording()
                    //else button is red self.audioRecorder.stopRecording()
                    //recordedAudioURL = audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: "")
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
                    
                    AudioPlayerView(audioPlayer: audioPlayer, audioURL: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""))
                        .opacity(audioRecorder.isRecording || !hasRecording ? 0 : 0.8)
                    
                    
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
