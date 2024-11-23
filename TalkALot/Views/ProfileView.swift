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
    //optional values for when viewing another persons profile
    var isExploringProfile = false // true when viewing a profile of an account other than the authorized user
    var exploredProfileUID = "" // UID of the profile being explored
    @Binding var showProfileMenuView: Bool
    
    @ObservedObject var audioPlayer = AudioPlayer()
    @EnvironmentObject var currentUserYaps: UserYapList
    @EnvironmentObject var currentUserProfile: UserProfile
    
    @State private var selectedItemID: UUID? = nil
    @State private var showSlider: Bool = false
    @State private var showAlert = false
    @State private var selectedFilter: Filter = .shared
    @State private var isEditingProfile = false
    @State private var isImagePickerPresented = false
    @State var showEditUsernameView: Bool = false
    @State var showEditNameView: Bool = false

    
    var exploredUserProfile = UserProfile()
    var exploredUserYaps = UserYapList()
    @State var loading = false

    
    var body: some View {
        ZStack(alignment: .leading) {
            NavigationView {
                GeometryReader { geometry in
                    VStack(alignment: .leading) {
                        // Profile content
                        if isEditingProfile {
                            HStack{ // Title and done button for when editing profile
                                Spacer()
                                Text("Edit Profile")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Button(action: {
                                    // Done editing profile
                                    isEditingProfile = false
                                    updateDisplayName(to: currentUserProfile.username) { error in
                                        if let error = error {
                                            print("Failed to update display name:", error)
                                        }
                                    }
                                }) {
                                    Text("Done")
                                        .font(.system(size: 12, design: .rounded))
                                        .padding()
                                        .frame(width: 120, height: 30)
                                }
                                .padding(.leading, 14)
                            }
                        }
                        HStack {
                            isEditingProfile ? Spacer() : nil
                            Button(action: {
                                // change profile picture
                                isImagePickerPresented = true
                            }) {
                                VStack {
                                    if currentUserProfile.profileImage != nil {
                                        Image(uiImage: isExploringProfile ? exploredUserProfile.profileImage! : currentUserProfile.profileImage!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 90, height: 90)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                            .shadow(radius: 10)
                                    } else {
                                        Image(systemName: "person.crop.circle.fill.badge.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 90, height: 90)
                                            .onTapGesture {
                                                isImagePickerPresented = true
                                            }
                                    }
                                    if isEditingProfile {
                                        Text("Edit profile picture")
                                            .font(.system(size: 12, design: .rounded))
                                            .padding()
                                    }else {
                                        Text(isExploringProfile ? exploredUserProfile.name : currentUserProfile.name)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(AppColors.textPrimary)
                                            
                                    }
                                }
                                .padding(.leading, 20)
                                
                            }
                            .disabled(!isEditingProfile)
                            isEditingProfile ? Spacer() : nil
                            if !isEditingProfile {
                                VStack {
                                    Text(isExploringProfile ? exploredUserProfile.username : currentUserProfile.username)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.textPrimary)
                                    HStack {
                                        Text("\(isExploringProfile ? exploredUserProfile.followers.count : currentUserProfile.followers.count) followers")
                                            .font(.system(size: 12, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Text("|")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(AppColors.highlightSecondary)
                                        Text("\(isExploringProfile ? exploredUserProfile.following.count : currentUserProfile.following.count) following")
                                            .font(.system(size: 12, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                    Text("\(isExploringProfile ? exploredUserYaps.yaps.count : currentUserYaps.yaps.count) Yaps")
                                        .font(.system(size: 12, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                if isExploringProfile {
                                    Button(action: {
                                        // follow the user if not already
                                        if !currentUserProfile.following.contains(exploredProfileUID) {
                                            currentUserProfile.followUser(followedUID: exploredProfileUID) { success, error in
                                                if success {
                                                    currentUserProfile.following.append(exploredProfileUID)
                                                    exploredUserProfile.followers.append(currentUserProfile.currentUUID ?? "")
                                                    print("Successfully followed user!")
                                                } else {
                                                    print("Failed to follow user: \(error ?? "Unknown error")")
                                                }
                                            }
                                        }else { // already following user, so unfollow action
                                            currentUserProfile.unfollowUser(unfollowedUID: exploredProfileUID) { success, error in
                                                if success {
                                                    currentUserProfile.following.removeAll{$0 == exploredProfileUID}
                                                    exploredUserProfile.followers.removeAll{$0 == currentUserProfile.currentUUID ?? ""}
                                                    print("Successfully unfollowed user!")
                                                } else {
                                                    print("Failed to unfollow user: \(error ?? "Unknown error")")
                                                }
                                            }
                                        }
                                    }) {
                                        Text(currentUserProfile.following.contains(exploredProfileUID) ? "Unfollow" : "Follow")
                                            .font(.system(size: 12, design: .rounded))
                                            .padding()
                                            .frame(width: 90, height: 30)
                                        
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(currentUserProfile.following.contains(exploredProfileUID) ? AppColors.overlayBackground : AppColors.highlightSecondary) // Set background color for button
                                                    .shadow(radius: 2) // Optional shadow for better visibility
                                            )
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    .padding(.leading, 14)
                                }
                                Spacer()
                            }
                        }
                        if !isEditingProfile && !isExploringProfile{
                            HStack {
                                Button(action: {
                                    // Toggle Edit Profile
                                    isEditingProfile = true
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
                                    currentUserYaps.fetchDraftYaps()
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.blue) // Apply your desired color
                                        .font(.system(size: 20)) // Set the size of the icon
                                        .frame(width: 45)
                                }
                                
                            }
                            .padding(.vertical, 10)
                        }else if !isExploringProfile {
                            //Edit profile attributes
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(AppColors.textSecondary)
                                HStack {
                                    Button(action: {
                                        showEditNameView.toggle()
                                    }) {
                                        Text("Name")
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                            .frame(width: 100,alignment: .leading)
                                        Text(currentUserProfile.name)
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                    }
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(AppColors.textSecondary)
                                HStack {
                                    Button(action: {
                                        showEditUsernameView.toggle()
                                    }) {
                                        Text("Username")
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                            .frame(width: 100,alignment: .leading)
                                        
                                        Text(currentUserProfile.username)
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                    }
                                    
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(AppColors.textSecondary)
                                HStack {
                                    Button(action: {
                                        
                                    }) {
                                        Text("Email")
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                            .frame(width: 100,alignment: .leading)
                                        Text(currentUserProfile.email)
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                    }
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(AppColors.textSecondary)
                                HStack {
                                    Button(action: {
                                        
                                    }) {
                                        Text("Birthdate")
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                            .frame(width: 100,alignment: .leading)
                                        Text(currentUserProfile.birthdate)
                                            .font(.system(size: 20, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .padding(.horizontal, 5)
                                    }
                                }
                                //
                            }
                        }
                        
                        if !isEditingProfile {
                            if !isExploringProfile {
                                HStack (spacing: 20) {
                                    Spacer()
                                    Button(action: {
                                        selectedFilter = .shared
                                        currentUserYaps.fetchSharedYaps(){}
                                    }) {
                                        VStack{
                                            Image(systemName: "list.bullet")
                                                .foregroundStyle(selectedFilter == .shared ? .blue : .gray)
                                                .font(.system(size: 25))
                                                .frame(width: 45)
                                            //                                    Text("Private")
                                            //                                        .font(.system(size: 12, design: .rounded))
                                            //                                        .multilineTextAlignment(.leading)
                                            //                                        .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        selectedFilter = .draft
                                        currentUserYaps.fetchDraftYaps()
                                    }) {
                                        VStack{
                                            Image(systemName: "lock.fill")
                                                .foregroundStyle(selectedFilter == .draft ? .blue : .gray)
                                                .font(.system(size: 25))
                                                .frame(width: 45)
                                            //                                    Text("Public")
                                            //                                        .font(.system(size: 12, design: .rounded))
                                            //                                        .multilineTextAlignment(.leading)
                                            //                                        .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                    Spacer()
                                    Button(action: {
                                        selectedFilter = .liked
                                        currentUserYaps.fetchLikedYaps()
                                    }) {
                                        VStack {
                                            Image(systemName: "heart")
                                                .foregroundStyle(selectedFilter == .liked ? .blue : .gray)
                                                .font(.system(size: 25))
                                                .frame(width: 45)
                                            //                                    Text("Liked")
                                            //                                        .font(.system(size: 12, design: .rounded))
                                            //                                        .multilineTextAlignment(.leading)
                                            //                                        .foregroundStyle(AppColors.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 14)
                        }
                            
                            ScrollView {
                                ForEach(isExploringProfile ? exploredUserYaps.yaps : currentUserYaps.yaps) { yap in
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
                                            Image(uiImage: yap.yapImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Rectangle())
                                                .shadow(radius: 10)
                                                
                                            
                                            if selectedItemID == yap.id && showSlider && !isExploringProfile {
                                                Menu {
                                                    Button("Share Yap") {
                                                        currentUserYaps.shareYap(by: selectedItemID)
                                                    }
                                                    Button("Edit Yap") {
                                                        // Add edit action here
                                                    }
                                                    Button("Delete Yap", role: .destructive) {
                                                        // Add delete action here
                                                    }
                                                } label: {
                                                    Image(systemName: "ellipsis.circle")
                                                        .foregroundStyle(.blue) // Apply your desired color
                                                        .font(.system(size: 20)) // Set the size of the icon
                                                        .frame(width: 45)
                                                }
                                                .contentShape(Rectangle()) // Ensures the tap area is confined to the label
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // Toggle selected item and slider visibility
                                            if selectedItemID == yap.id {
                                                // no need to unshow currently viewed yap
                                                //showSlider.toggle()
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
                                                        self.audioPlayer.startPlayback(url: yap.url){}
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
                                                .disabled(isExploringProfile)
                                                .opacity(isExploringProfile ? 0 : 1)
                                                .frame(width: 50)
                                                .frame(width: 50)
                                                .deleteConfirmation(showAlert: $showAlert) {
                                                    currentUserYaps.removeYap(by: selectedItemID)
                                                    //TODO: delete from firebase
                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //end of scroll
                        
                        Spacer()
                    }
                    .padding(5)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(image: $currentUserProfile.profileImage)
                            .onDisappear(){
                                uploadProfileImage(currentUserProfile.profileImage ?? UIImage()) { url in
                                       if let url = url {
                                           updateProfilePicture(with: url)
                                       }
                                   }
                            }
                    }
                    EditTextView(showEditTextView: $showEditUsernameView, text: $currentUserProfile.username, placeholder: "Enter new username")
                        .offset(y: showEditUsernameView ? 0 : UIScreen.main.bounds.height)
                        .opacity(1)
                        .animation(.linear(duration: 0.05), value: showEditUsernameView)
                    EditTextView(showEditTextView: $showEditNameView, text: $currentUserProfile.name, placeholder: "Enter new name")
                        .offset(y: showEditNameView ? 0 : UIScreen.main.bounds.height)
                        .opacity(1)
                        .animation(.linear(duration: 0.05), value: showEditNameView)
                        
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .background(AppColors.background)
                .defaultTextColor()
            }
        }
        .onAppear(){
            print(currentUserProfile.username)
            if isExploringProfile {
                
                print(exploredUserYaps.yaps.count)
                print(exploredUserProfile.name)
                print(exploredUserProfile.birthdate)
                
            }else{
                currentUserProfile.downloadProfileByUID(fetchFromUID: Auth.auth().currentUser?.uid ?? "")
                currentUserYaps.fetchDraftYaps()
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

enum Filter: Int {
    case none
    case saved
    case draft
    case shared
    case liked
}

// update current users display name in firebase auth
func updateDisplayName(to newDisplayName: String, completion: @escaping (Error?) -> Void) {
    // Get the current user
    if let user = Auth.auth().currentUser {
        // Create a change request
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        
        // Commit the profile change
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Display name updated successfully to \(newDisplayName)")
                completion(nil)
            }
        }
    } else {
        print("No user is signed in")
        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is signed in"]))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(showProfileMenuView: .constant(false))
            .environmentObject(UserYapList())
    }
}
