//
//  ProfileView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-08-08.
//

import SwiftUI
import FirebaseAuth
import Firebase
import AVFoundation

struct ProfileView: View {
    @Binding var showProfileMenuView: Bool
    @ObservedObject var audioPlayer = AudioPlayer()

    @State private var yaps: [Yap] = []
    @State private var audioURLs: [URL] = []
    @State private var selectedItemID: UUID? = nil
    @State private var showSlider: Bool = false

    init(showProfileMenuView: Binding<Bool>) {
        self._showProfileMenuView = showProfileMenuView
        self._audioURLs = State(initialValue: [
            Bundle.main.url(forResource: "sample1", withExtension: "m4a")!,
            Bundle.main.url(forResource: "sample3", withExtension: "m4a")!
        ])
        self._yaps = State(initialValue: [
            Yap(title: "Yap 1", url: Bundle.main.url(forResource: "sample1", withExtension: "m4a")!, date: "2024-08-09"),
            Yap(title: "Bing Bong", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "afgan rabba 5", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "song", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "love this app", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "yeehaw", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "mook", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "mikayla is wonderful", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "she is my girlfriend", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "i love her so much", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
            Yap(title: "AWWWWWW", url: Bundle.main.url(forResource: "sample3", withExtension: "m4a")!, date: "2024-07-13"),
        ])
    }

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationView {
                GeometryReader { geometry in
                    VStack(alignment: .leading) {
                        // Profile content
                        HStack {
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(AppColors.highlightPrimary)
                                .overlay(
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 90, height: 90)
                                        .foregroundColor(Color.gray)
                                )
                            VStack {
                                Text("Username")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(AppColors.textPrimary)
                                HStack {
                                    Text("0 followers")
                                        .font(.system(size: 12, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Text("|")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.highlightSecondary)
                                    Text("0 following")
                                        .font(.system(size: 12, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            }
                            .padding()
                            Spacer()
                        }

                        Button(action: {
                            // Edit profile action
                        }) {
                            Text("Edit")
                                .font(.system(size: 12, design: .rounded))
                                .frame(width: 40, height: 25)
                                .background(Color.clear)
                                .foregroundColor(AppColors.textSecondary)
                                .overlay(
                                    Capsule()
                                        .stroke(AppColors.textSecondary, lineWidth: 2)
                                )
                        }
                        .padding()
                        .padding(.leading, 14)

                        ScrollView {
                            ForEach(yaps) { yap in
                                    VStack {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .opacity(0.5)// Set the color of the line
                                            .frame(height: 0.75) // Set the thickness of the line
                                        HStack {
                                            VStack (alignment: .leading) {
                                                Text(yap.title)
                                                    .foregroundStyle(AppColors.textPrimary)
                                                Text(yap.date)
                                                    .foregroundStyle(AppColors.textSecondary)
                                            }
                                            Spacer()
                                            
                                            if selectedItemID == yap.id {
                                                Button(action: {
                                                    // Add the action for the button here
                                                }) {
                                                    Image(systemName: "ellipsis.circle")
                                                        .foregroundStyle(.blue) // Apply your desired color
                                                        .font(.system(size: 20)) // Set the size of the icon
                                                        .frame(width: 45)
                                                }
                                            }
                                        }
                                        .onTapGesture {
                                            // Toggle selected item and slider visibility
                                            if selectedItemID == yap.id {
                                                showSlider.toggle()
                                            } else {
                                                selectedItemID = yap.id
                                                showSlider = true
                                                audioPlayer.initializePlayer(url: yap.url)
                                            }
                                        }
                                        .padding(.vertical, 7)
                                        .background(AppColors.background)
                                        .cornerRadius(10)

                                        if showSlider && (selectedItemID == yap.id) {
                                            PlaybackSlider(
                                                value: Binding(
                                                    get: {
                                                        audioPlayer.currentTime
                                                    },
                                                    set: { (newValue) in
                                                        audioPlayer.seek(to: newValue)
                                                    }
                                                ),
                                                range: 0...audioPlayer.duration,
                                                step: 0.01,
                                                thumbSize: 30,
                                                isInList: true
                                            )
                                            .padding(.horizontal)
                                            HStack {
                                                Text(formatTime(audioPlayer.currentTime))
                                                    .frame(width: 50, alignment: .leading)
                                                Spacer()
                                                // Skip backwards button
                                                Button(action: {
                                                    let skipInterval: TimeInterval = -5
                                                    let newTime = max(self.audioPlayer.currentTime + skipInterval, 0)
                                                    self.audioPlayer.seek(to: newTime)
                                                }) {
                                                    Image(systemName: "gobackward.5")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30)
                                                }
                                                .foregroundStyle(.blue)
                                                
                                                // Play/Pause button
                                                Button(action: {
                                                    if self.audioPlayer.isPlaying {
                                                        self.audioPlayer.pausePlayback()
                                                    } else {
                                                        self.audioPlayer.startPlayback(url: yap.url)
                                                    }
                                                }) {
                                                    Image(systemName: self.audioPlayer.isPlaying && self.audioPlayer.currentTime != 0.0 ? "pause.circle.fill" : "play.circle.fill")
                                                        .resizable()
                                                        .frame(width: 50, height: 50)
                                                }
                                                .foregroundStyle(.blue)
                                                .padding()
                                                
                                                // Skip forwards button
                                                Button(action: {
                                                    let skipInterval: TimeInterval = 5
                                                    let newTime = min(self.audioPlayer.currentTime + skipInterval, self.audioPlayer.duration)
                                                    self.audioPlayer.seek(to: newTime)
                                                }) {
                                                    Image(systemName: "goforward.5")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 30, height: 30)
                                                }
                                                .foregroundStyle(.blue)
                                                Spacer()
                                                Button(action: {
                                                    // Add the action for the button here
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundStyle(.blue) // Apply your desired color
                                                        .font(.system(size: 24)) // Set the size of the icon
                                                }
                                                .frame(width: 50)
                                            }
                                        }
                                        
                                    }
                                
                            }
                        }

                        
                        Spacer()
                    }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .background(AppColors.background)
                .defaultTextColor()
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct Yap: Identifiable {
    var id: UUID = UUID()
    var title: String
    let url: URL
    let date: String
}






struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showProfileMenuView: .constant(false))
    }
}
