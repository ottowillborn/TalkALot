//
//  EditAudioView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-04.
//

import SwiftUI

struct EditAudioView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Binding var waveformData: [CGFloat]
    var audioURL: URL
    @State var toggleCutAudio = false
    @State var toggleTrimAudio = false
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                AudioPlayerView(
                    audioPlayer: audioPlayer,
                    waveformData: $waveformData,
                    audioURL: audioURL,
                    isEditing: toggleCutAudio || toggleTrimAudio
                )
                HStack{
                    if !self.toggleCutAudio {
                        Button(action: {
                            self.toggleCutAudio = true
                        }) {
                            Text("cut audio")
                        }
                    } else {
                        Button(action: {
                            do {
                                // cut audio in editor and store new file in existing URL's place, replacing it
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
                            Text("Confirm Cut")
                        }
                    }
                    
                    if !self.toggleTrimAudio {
                        Button(action: {
                            self.toggleTrimAudio = true
                        }) {
                            Text("trim audio")
                        }
                    } else {
                        Button(action: {
                            do {
                                // trim audio in editor and store new file in existing URL's place, replacing it
                                // TODO: undo option for trims
                                let audioEditor = try AudioEditor(fileURL: audioURL)
                                try audioEditor.trimAudio(startTime: audioPlayer.lowerValue, endTime: audioPlayer.upperValue, outputURL: audioURL)
                                self.audioPlayer.initializePlayer(url: audioURL) // re-initialize audio player as file has changed
                                self.waveformData = WaveformProcessor.generateWaveformData(for: audioURL) // regenerate waveform as audio has changed
                                self.toggleTrimAudio = false // reset toggle cut
                            } catch {
                                print("Failed to trim audio: \(error.localizedDescription)")
                            }
                        }) {
                            Text("Confirm trim")
                        }
                    }
                    //change speed
                    
                }// end of edit btns
                Button(action: {
                    self.toggleCutAudio = false
                    self.toggleTrimAudio = false
                }) {
                    Text("cancel")
                }
                
            }
            .onAppear{audioPlayer.initializePlayer(url: self.audioURL)} //initialize player on load: makes edit tabs visible when selected
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        
    }
}
