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
    @Binding var showProfileMenuView: Bool // Binding to control visibility
    @State var showEditTextView: Bool = false // Binding to control visibility
    @State var isEditingTitle: Bool = true
    @State var yapName = ""



    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                
                VStack {
                    if !isEditing && !hasRecording{
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
                                .fill(audioRecorder.isRecording ? AppColors.highlightPrimary : AppColors.textPrimary)
                                .frame(width: size, height: size) // Adjust circle size based on amplitude, with a maximum limit
                                .overlay(
                                    Circle()
                                        .stroke(audioRecorder.isRecording ? Color.white : AppColors.highlightPrimary, lineWidth: 4)
                                        .frame(width: 100, height: 100)
                                )
                                .overlay(
                                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                        .foregroundColor(audioRecorder.isRecording ? .white : AppColors.highlightPrimary)
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
                                    .foregroundStyle(AppColors.textSecondary)
                                
                            }
                        }
                        Spacer()
                        Button(action: {
                            if isEditing {
                                //TODO: create new Yap() object - title, audio file, waveform?
                            } else {
                                // store original
                                self.storeBackup()
                                isEditing.toggle()
                            }
                        }) {
                            if isEditing {
                                Text("Save")
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppColors.textSecondary)
                            } else {
                                Image(systemName: "crop")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            
                        }
                        .opacity((hasRecording && !audioRecorder.isRecording) ? 1 : 0)
                    }
                    .padding()
                    HStack  {
                        Text(yapName.isEmpty ? "Edit Yap Title": yapName)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.leading) // Align text to the left
                            .padding(.horizontal)
                        
                        Button(action: {
                            showEditTextView.toggle()
                        }) {
                            Image(systemName: "pencil")
                                .foregroundStyle(.primary)
                                .font(.system(size: 25)) // Set the size of the icon
                                .fontWeight(.bold)
                                .padding(.horizontal)
                        }
                        Spacer()
                        Button(action: {
                            
                                //TODO: create new Yap() object - title, audio file, waveform?
                            
                        }) {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(.horizontal)

                        }
                        .opacity((hasRecording && !isEditing) ? 1 : 0)
                    }
                    .opacity(hasRecording ? 1 : 0)
                    .padding(.bottom)
                    
                    
                    
                    if hasRecording && !audioRecorder.isRecording{
                        AudioPlayerView(
                            audioPlayer: audioPlayer,
                            waveformData: $waveformData,
                            audioURL: audioRecorder.audioRecorder?.url ?? URL(fileURLWithPath: ""),
                            isEditing: isEditing
                        )
                    }
                    
                    Button(action: {
                        //TODO: clear all state recording data
                        hasRecording = false
                    }) {
                        if hasRecording {
                            Image(systemName: "mic")
                                .foregroundStyle(AppColors.textSecondary)
                                .font(.system(size: 25)) // Set the size of the icon
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 70)
                    .opacity(isEditing ? 0 : 1)
                    
                    
                }
                
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                withAnimation {
                                    showProfileMenuView.toggle()
                                }
                            }) {
                                Circle()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(AppColors.highlightPrimary)
                                    .overlay(
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(Color.gray)
                                    )
                            }
                            Text(isEditing ? "Edit" : "Record")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.leading) // Align text to the left
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                // View slide up from bottom with keyboard when editing text
                EditTextView(showEditTextView: $showEditTextView, text: $yapName)
                    .offset(y: showEditTextView ? 0 : UIScreen.main.bounds.height)
                    .opacity(1)
                    .animation(.linear(duration: 0.05), value: showEditTextView)
            }
            .background(AppColors.background)
            .defaultTextColor()
            
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


//struct RecordView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordView()
//    }
//}
