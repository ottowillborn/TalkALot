//
//  HomeView.swift
//  TalkALot
//
//  Created by Otto Willborn on 2024-07-22.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct HomeView: View {
    
    @State private var userEmail = Auth.auth().currentUser?.email
    @Binding var showProfileMenuView: Bool
    @ObservedObject var audioPlayer = AudioPlayer()
    @State private var currentIndex: Int = 0
    @EnvironmentObject var currentUserProfile: UserProfile
    @EnvironmentObject var publicYaps: UserYapList
    @State private var loading = false
    
    
    var body: some View {
        NavigationView {
        GeometryReader { geometry in
            ZStack {
                AppColors.background.edgesIgnoringSafeArea(.all)
                
                if currentIndex < publicYaps.yaps.count {
                    VStack {
                        // Add a spacer for the safe area at the top
                        //                        Spacer().frame(height: geometry.safeAreaInsets.top)
                        
                        // Title
                        Text(publicYaps.yaps[currentIndex].title)
                            .font(.title)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 10)
                        
                        // Card Stack
                        CardView(yap: publicYaps.yaps[currentIndex]) { direction in
                            handleSwipe(direction: direction)
                        }
                        .padding(.bottom, 20)
                        
                        // Playback Slider
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
                        
                        // Playback Controls
                        HStack {
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
                            
                            Spacer()
                            
                            // Play/Pause button
                            Button(action: {
                                if self.audioPlayer.isPlaying {
                                    self.audioPlayer.pausePlayback()
                                } else {
                                    self.audioPlayer.startPlayback(url: publicYaps.yaps[currentIndex].url)
                                }
                            }) {
                                Image(systemName: self.audioPlayer.isPlaying && self.audioPlayer.currentTime != 0.0 ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                            .foregroundStyle(.blue)
                            .padding()
                            
                            Spacer()
                            
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
                        }
                        .padding(.horizontal, 40)
                        
                        // Navigation Buttons
                        HStack {
                            Button(action: {
                                goForward()
                            }) {
                                Image(systemName: "backward.fill")
                                    .foregroundColor(.black)
                                    .font(.title)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(currentIndex == 0)
                            
                            Spacer()
                            
                            Button(action: {
                                goPrevious()
                            }) {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(.black)
                                    .font(.title)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(currentIndex == publicYaps.yaps.count - 1)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, geometry.safeAreaInsets.bottom) // Adjust for bottom safe area
                    }
                    
                    
                } else {
                    Text("No more yaps")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }.navigationBarItems(
                leading:
                    HStack{
                        Button(action: {
                            // Show profile view
                            withAnimation {
                                showProfileMenuView.toggle()
                            }
                        }) {
                            VStack {
                                if currentUserProfile.profileImage != nil {
                                    Image(uiImage: currentUserProfile.profileImage!)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 10)
                                } else {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                }
                                
                                
                                
                            }
                        }
                        Text("Home")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.leading) // Align text to the left
                        .foregroundStyle(AppColors.textPrimary)})
            
            
            
        }
        .onAppear {
            loading = true
            publicYaps.fetchPublicYaps {
                loading = false
                playAudio(for: publicYaps.yaps[currentIndex])
            }
        }
        .onChange(of: currentIndex) { newIndex in
            if newIndex < publicYaps.yaps.count {
                playAudio(for: publicYaps.yaps[newIndex])
            }
        }
    }
    }
    
    
    
    
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    private func goPrevious() {
        if currentIndex < publicYaps.yaps.count-1 {
            currentIndex += 1
        }
    }
    
    private func goForward() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    
    private func handleSwipe(direction: SwipeDirection) {
        switch direction {
        case .right: // Go forward
            if currentIndex < publicYaps.yaps.count - 1 {
                currentIndex += 1
            } else {
                print("last Yap")
            }
        case .left: // Go backward
            if currentIndex > 0 {
                currentIndex -= 1
            } else {
                print("first Yap")
            }
        }
    }
    
    private func playAudio(for yap: Yap) {
        audioPlayer.startPlayback(url: yap.url)
    }
    
    
}
