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
    @State var isEditing: Bool = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                if !isEditing && !hasRecording{
                    if !audioRecorder.isRecording {
                        if !hasRecording {
                            Text("Click to start recording")
                        }
                    } else {
                        Text("Click to stop recording")
                    }
                    Button(action: {
                        if !audioRecorder.isRecording {
                            self.audioRecorder.startRecording()
                        } else {
                            self.audioRecorder.stopRecording()
                            self.audioPlayer.seek(to: 0) // Start from beginning if new recording
                            waveformData = WaveformProcessor.generateWaveformData(for: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""))
                            hasRecording = true
                        }
                    }) {
                        let baseSize: CGFloat = (hasRecording && !audioRecorder.isRecording ? 50 : 80)
                        let maxSize: CGFloat = 160
                        let amplitude = audioRecorder.audioAmplitude * 400
                        let size = min(baseSize + amplitude, maxSize)
                        
                        Circle()
                            .fill(audioRecorder.isRecording ? AppColors.highlightPrimary : AppColors.accent)
                            .frame(width: size, height: size) // Adjust circle size based on amplitude, with a maximum limit
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 100, height: 100)
                            )
                            .overlay(
                                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: hasRecording && !audioRecorder.isRecording ? 25 : 40))
                            )
                        
                    }
                    .padding()
                }

                HStack(spacing: 40) {
                    if isEditing {
                        // Cancel
                        Button(action: {
                            self.revertAudio()
                            isEditing.toggle()
                        }) {
                            Text("Cancel")
                                .fontWeight(.bold)
                        }
                    }
                    Spacer()
                    // proceed, save, edit btns etc
                    Button(action: {
                        if isEditing {
                            //save
                        } else {
                            // store original
                            self.storeBackup()
                            isEditing.toggle()
                        }
                    }) {
                        if isEditing {
                            Text("Save")
                                .fontWeight(.bold)
                        } else {
                            Image(systemName: "crop")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                        }
                        
                    }
                    .opacity((hasRecording && !audioRecorder.isRecording) ? 1 : 0)
                }
                .padding(15)
                    
                    
                
                if hasRecording && !audioRecorder.isRecording{
                    AudioPlayerView(
                        audioPlayer: audioPlayer,
                        waveformData: $waveformData,
                        audioURL: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""),
                        isEditing: isEditing
                    )
                }
                if !isEditing {
                    Button(action: {
                        hasRecording = false
                    }) {
                        if hasRecording {
                            Image(systemName: "mic")
                                .foregroundStyle(.primary)
                                .font(.system(size: 25)) // Set the size of the icon
                                .fontWeight(.bold)
                            
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 70)
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    HStack {
                        Button(action: {
                            // Action to perform when button is tapped
                        }) {
                            Circle()
                                .frame(width: 35, height: 35)
                                .padding(.leading, -10)
                                .foregroundStyle(AppColors.highlightPrimary)
                                .overlay(
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color.gray)
                                        .padding(.leading,-10)
                                )
                        }
                        Text(isEditing ? "Edit" : "Record")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.leading) // Align text to the left
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.leading,-10)
                    }
                    .padding(.bottom,15)
                    
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    //uses self to revert to stored audio file
    func revertAudio() {
        do {
            let audioURL = audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: "")
            let backupURL = audioURL.deletingPathExtension().appendingPathExtension("backup.m4a")
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.replaceItemAt(audioURL, withItemAt: backupURL)
            }
            self.audioPlayer.initializePlayer(url: audioURL) // re-initialize audio player as file has changed
            self.waveformData = WaveformProcessor.generateWaveformData(for: audioURL) // regenerate waveform as audio has changed
        } catch {
            print("Failed to revert audio: \(error.localizedDescription)")
        }
    }
    
    //uses self to store a backup of audio file
    func storeBackup() {
        do {
            let audioURL = audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: "")
            let backupURL = audioURL.deletingPathExtension().appendingPathExtension("backup.m4a")
            if !FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.copyItem(at: audioURL, to: backupURL)
            }
        } catch {
            print("Failed to store backup: \(error.localizedDescription)")
        }
    }
}


struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
