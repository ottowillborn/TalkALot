//
//  HomeScreen.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-11-19.
//
import SwiftUI
import FirebaseAuth
import Firebase

struct HomeScreen: View {
    @State private var userEmail = Auth.auth().currentUser?.email
    @Binding var showProfileMenuView: Bool
    @ObservedObject var audioPlayer = AudioPlayer()
    @State private var currentIndex: Int = 0
    @EnvironmentObject var currentUserProfile: UserProfile
    @EnvironmentObject var publicYaps: UserYapList
    @State private var loading = false

    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)

            if currentIndex < publicYaps.yaps.count {
                VStack {
                    // Title
                    Text(publicYaps.yaps[currentIndex].title)
                        .font(.title)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 10)

                    // Card Stack
                    CardView(yap: publicYaps.yaps[currentIndex]) { direction in
                        handleSwipe(direction: direction)
                    }
                    .padding(.bottom, 20) // Add space between the card and the controls

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
                    .padding(.bottom, 20) // Space between playback controls and navigation buttons

                    // Navigation Buttons (Previous/Next)
                    HStack {
                        Spacer()

                        Button(action: {
                            goForward()
                        }) {
                            Image(systemName: "backward.fill")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == 0) // Disable if at the first Yap

                        Spacer()

                        Button(action: {
                            goPrevious()
                        }) {
                            Image(systemName: "forward.fill")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == publicYaps.yaps.count - 1) // Disable if at the last Yap

                        Spacer()
                    }
                    .padding(.horizontal, 40)
                }
            } else {
                Text("No more yaps")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            loading = true
            publicYaps.fetchPublicYaps {
                loading = false
                print("Yaps fetched")
                playAudio(for: publicYaps.yaps[currentIndex])
            }
        }
        .onChange(of: currentIndex) { newIndex in
            if newIndex < publicYaps.yaps.count {
                playAudio(for: publicYaps.yaps[newIndex])
            }
        }
        .background(Color.black.opacity(0.05))
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

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
       
        let mockUserProfile = UserProfile()
        
        
        let mockPublicYaps = UserYapList()
        mockPublicYaps.yaps = [
            Yap(
                id: UUID(),
                title: "Relaxing Music",
                url: URL(string: "https://example.com/relaxing-music.mp3")!,
                yapImage: UIImage(systemName: "music.note")!,
                date: Date()
            ),
            Yap(
                id: UUID(),
                title: "Upbeat Track",
                url: URL(string: "https://example.com/upbeat-track.mp3")!,
                yapImage: UIImage(systemName: "music.note.list")!,
                date: Date()
            ),
            Yap(
                id: UUID(),
                title: "Soothing Sounds",
                url: URL(string: "https://example.com/soothing-sounds.mp3")!,
                yapImage: UIImage(systemName: "mic")!,
                date: Date()
            )
        ]
        
        return HomeScreen(showProfileMenuView: .constant(false))
            .environmentObject(mockUserProfile)
            .environmentObject(mockPublicYaps)
    }
}

private func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}


