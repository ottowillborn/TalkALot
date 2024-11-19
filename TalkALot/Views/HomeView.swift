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
    @Binding var showProfileMenuView: Bool // Binding to control visibility
    @ObservedObject var audioPlayer = AudioPlayer()

    @EnvironmentObject var publicYaps: UserYapList
    @State private var selectedItemID: UUID? = nil
    @State private var showSlider: Bool = false
    @State private var showAlert = false
    @State var profileImage: UIImage?
    @State var loading = false




    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main TabView with offset when profile view is shown
                NavigationView {
                    GeometryReader { geometry in
                        VStack {
                            //Home content
                            Button(action: {
                                loading.toggle()
                                publicYaps.fetchPublicYaps{
                                    loading.toggle()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundStyle(.blue) // Apply your desired color
                                    .font(.system(size: 20)) // Set the size of the icon
                                    .frame(width: 45)
                            }
                            if loading {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                                    .scaleEffect(2)
                                Spacer()
                            } else {
                                ScrollView{
                                    ForEach(publicYaps.yaps) { yap in
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
                                                        publicYaps.shareYap(by: selectedItemID)
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
                                                        publicYaps.removeYap(by: selectedItemID)
                                                        //TODO: delete from firebase
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .navigationBarItems(
                            leading:
                                HStack{
                                    Button(action: {
                                        // Show profile view
                                        withAnimation {
                                            showProfileMenuView.toggle()
                                        }
                                    }) {
                                        VStack {
                                            if let profileImage = profileImage {
                                                Image(uiImage: profileImage)
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
                                        .onAppear(){
                                            fetchProfilePicture { image in
                                                if let image = image {
                                                    DispatchQueue.main.async {
                                                        self.profileImage = image
                                                    }
                                                }
                                            }
                                            loading.toggle()
                                            publicYaps.fetchPublicYaps{
                                                loading.toggle()
                                            }
                                            
                                            
                                        }
                                    }
                                    Text("Home")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading) // Align text to the left
                                        .foregroundStyle(AppColors.textPrimary)
                                }
                        )
                        
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


//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
