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
    @State var navigateToExploredProfile = false
    @State var exploredUserProfile = UserProfile()
    @State var exploredUserYaps = UserYapList()
    @State private var currentIndex: Int = 0
    @State private var loading = false
    
    @Binding var showProfileMenuView: Bool
    
    @ObservedObject var audioPlayer = AudioPlayer()
   
    @EnvironmentObject var currentUserProfile: UserProfile
    @EnvironmentObject var publicYaps: UserYapList
    
    var body: some View {
        NavigationView {
        GeometryReader { geometry in
            
            ZStack {
                AppColors.background.edgesIgnoringSafeArea(.all)
                // Show loading wheel when yaps or profile are being fetched
                if loading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                        .scaleEffect(2)
                    Spacer()
                } else {
                    
                    if currentIndex < publicYaps.yaps.count {
                        
                        VStack {
                            
                            // Card Stack
                            CardView(yap: publicYaps.yaps[currentIndex]) { direction in
                                handleSwipe(direction: direction)
                            }
                            .padding(.bottom, 20)
                            VStack (alignment: .leading) {
                                // Title
                                Text(publicYaps.yaps[currentIndex].title)
                                    .font(.title)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.top, 10)
                                
                                // Button to perform actions for navLink BEFORE navigation
                                Button(action: {
                                    // Store explored User info
                                    exploredUserProfile.downloadProfileByUID(fetchFromUID: publicYaps.yaps[currentIndex].postedBy ?? "")
                                    loading = true
                                    // Get the shared yaps of the explored user
                                    exploredUserYaps.fetchSharedYaps(fetchFromUID: publicYaps.yaps[currentIndex].postedBy ?? ""){
                                        navigateToExploredProfile = true // Trigger navigation
                                        loading = false
                                    }
                                }) {
                                    Text(publicYaps.yaps[currentIndex].creatorUsername)
                                        .font(.system(size: 14, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                .padding(.leading, 3)
                                
                                NavigationLink(
                                    // Navigate to profile view with flags for exploring a user other than themselves
                                    destination: ProfileView(
                                        isExploringProfile: true,
                                        exploredProfileUID: publicYaps.yaps[currentIndex].postedBy ?? "",
                                        showProfileMenuView: $showProfileMenuView,
                                        exploredUserProfile: exploredUserProfile,
                                        exploredUserYaps: exploredUserYaps
                                    ),
                                    isActive: $navigateToExploredProfile
                                ) {
                                    EmptyView() // Invisible NavigationLink
                                }
                                .padding(.leading, 3)

                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure the VStack aligns to the left
                            .padding(.leading, 12)
                            .padding(.bottom, 10)

                              
                            
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
                                        self.audioPlayer.startPlayback(url: publicYaps.yaps[currentIndex].url){}
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
                            
                        }
                        
                        
                    } else {
                        Text("No more yaps")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
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
            //only load when publicYaps is empty
            if publicYaps.yaps.isEmpty {
                loading = true
                publicYaps.fetchPublicYaps {
                    self.audioPlayer.initializePlayer(url: publicYaps.yaps[currentIndex].url)
                    loading = false
                    self.audioPlayer.startPlayback(url: publicYaps.yaps[currentIndex].url){}
                }
            }
            //print("current: \(Auth.auth().currentUser?.uid ?? "UID")")
        }
        .onDisappear(){
            self.audioPlayer.pausePlayback()
        }
        .onChange(of: currentIndex) { newIndex in
            if newIndex < publicYaps.yaps.count {
                self.audioPlayer.seek(to: 0)
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
        audioPlayer.startPlayback(url: yap.url){}
    }
    
    
}


