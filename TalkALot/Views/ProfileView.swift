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
    @EnvironmentObject var currentUserYaps: UserYapList
    
    @State private var audioURLs: [URL] = []
    @State private var selectedItemID: UUID? = nil
    @State private var showSlider: Bool = false
    @State private var showAlert = false
    @State private var selectedFilter: Filter = .none


    
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
                        HStack {
                            Button(action: {
                                // Edit profile action
                            }) {
                                Text("Edit Profile")
                                    .font(.system(size: 12, design: .rounded))
                                    .padding()
                                    .frame(width: 120, height: 30)

                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.overlayBackground) // Set background color for button
                                            .shadow(radius: 2) // Optional shadow for better visibility
                                    )
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(.leading, 14)
                            
                            
                            Button(action: {
                                // Share profile action
                            }) {
                                Text("Share Profile")
                                    .font(.system(size: 12, design: .rounded))
                                    .padding()
                                    .frame(width: 120, height: 30)

                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.overlayBackground) // Set background color for button
                                            .shadow(radius: 2) // Optional shadow for better visibility
                                    )
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(.leading, 14)
                            
                            Button(action: {
                            }) {
                                Image(systemName: "plus")
                                    .foregroundStyle(.blue) // Apply your desired color
                                    .font(.system(size: 20)) // Set the size of the icon
                                    .frame(width: 45)
                            }
                            
                        }
                        .padding(.vertical, 10)
                        
                        HStack (spacing: 20) {
                            Spacer()
                            Button(action: {
                                selectedFilter = .none
                            }) {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(selectedFilter == .none ? .blue : .gray)
                                    .font(.system(size: 25))
                                    .frame(width: 45)
                            }
                            Spacer()
                            Button(action: {
                                selectedFilter = .saved
                            }) {
                                Image(systemName: "bookmark")
                                    .foregroundStyle(selectedFilter == .saved ? .blue : .gray)
                                    .font(.system(size: 25))
                                    .frame(width: 45)
                            }
                            Spacer()
                            Button(action: {
                                selectedFilter = .liked
                            }) {
                                Image(systemName: "heart")
                                    .foregroundStyle(selectedFilter == .liked ? .blue : .gray)
                                    .font(.system(size: 25))
                                    .frame(width: 45)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                        
                        ScrollView {
                            ForEach(currentUserYaps.yaps) { yap in
                                VStack {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .opacity(0.5)// Set the color of the line
                                        .frame(height: 0.75) // Set the thickness of the line
                                    HStack {
                                        VStack (alignment: .leading) {
                                            Text(yap.title)
                                                .foregroundStyle(AppColors.textPrimary)
                                            Text(yap.date.formatted())
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                        Spacer()
                                        
                                        if (selectedItemID == yap.id) && showSlider {
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
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
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
                                                showAlert = true
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(.blue)
                                                    .font(.system(size: 24))
                                            }
                                            .frame(width: 50)
                                            .frame(width: 50)
                                            .deleteConfirmation(showAlert: $showAlert) {
                                                currentUserYaps.removeYap(by: selectedItemID)
                                            }
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
        .onDisappear {
            self.selectedItemID = nil
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
    let date: Date
}

enum Filter: Int {
    case none
    case saved
    case liked
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showProfileMenuView: .constant(false))
            .environmentObject(UserYapList())
    }
}
