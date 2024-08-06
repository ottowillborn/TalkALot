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
                if !toggleCutAudio && !toggleTrimAudio {
                    Menu {
                        // Cut Audio Option
                        if !self.toggleCutAudio {
                            Button(action: {
                                self.toggleCutAudio = true
                            }) {
                                Label("Cut", systemImage: "scissors")
                            }
                        }
                        
                        // Trim Audio Option
                        if !self.toggleTrimAudio {
                            Button(action: {
                                self.toggleTrimAudio = true
                            }) {
                                Label("Trim", systemImage: "crop")
                            }
                        }
                    } label: {
                        Label("Edit Audio", systemImage: "ellipsis.circle")
                    }
                } else if toggleCutAudio {
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
                        Label("Confirm Cut", systemImage: "scissors")
                    }
                } else if toggleTrimAudio {
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
                        Label("Confirm Trim", systemImage: "crop")
                    }
                }
                
                AudioPlayerView(
                    audioPlayer: audioPlayer,
                    waveformData: $waveformData,
                    audioURL: audioURL,
                    isEditing: toggleCutAudio || toggleTrimAudio
                )
                .padding(.horizontal)
                .border(Color.red)
                
                Button(action: {
                    self.toggleCutAudio = false
                    self.toggleTrimAudio = false
                }) {
                    Text("cancel")
                }
                
            }
            .onAppear{audioPlayer.initializePlayer(url: self.audioURL)} //initialize player on load: makes edit tabs visible when selected
        }
        
    }
}

struct EditAudioView_Previews: PreviewProvider {
    static var previews: some View {
        
        // Mock waveform data and audio URL
        let mockWaveformData: [CGFloat] = [0.2, 0.4, 0.6, 0.8, 0.6, 0.4, 0.2]
        let mockAudioURL = URL(fileURLWithPath: "/path/to/mock/audiofile.mp3")
        
        // Binding for waveform data
        @State var waveformDataBinding = mockWaveformData
        
        // Preview
        EditAudioView(
            audioPlayer: MockAudioPlayer(),
            waveformData: $waveformDataBinding,
            audioURL: mockAudioURL
        )
    }
}

