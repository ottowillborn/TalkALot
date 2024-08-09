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
    @Binding var showProfileMenuView: Bool // Binding to control visibility
    @State private var audioURLs: [URL] = [] // List of audio URLs
    @State private var waveformData: [CGFloat] = []
    @ObservedObject var audioPlayer = AudioPlayer()

    var body: some View {
        ZStack(alignment: .leading) {
                NavigationView {
                    GeometryReader { geometry in
                        
                        VStack (alignment: .leading) {
                            //Profile content
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
                                    //username
                                    Text("Username")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading) // Align text to the left
                                        .foregroundStyle(AppColors.textPrimary)
                                    HStack {
                                        //followers
                                        Text("0 " + "followers")
                                            .font(.system(size: 12, design: .rounded))
                                            .multilineTextAlignment(.leading) // Align text to the left
                                            .foregroundStyle(AppColors.textSecondary)
                                        Text("|")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .multilineTextAlignment(.leading) // Align text to the left
                                            .foregroundStyle(AppColors.highlightSecondary)
                                        //following
                                        Text("0 " + "following")
                                            .font(.system(size: 12, design: .rounded))
                                            .multilineTextAlignment(.leading) // Align text to the left
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                .padding()
                                
                                Spacer()
                                
                            }
                            
                            Button(action: {
                                //TODO: add edit profile functionality
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
                            Spacer()
                            
                            ScrollView {
                                VStack(spacing: 20) {
                                    ForEach(audioURLs, id: \.self) { url in
                                        AudioPlayerView(
                                            audioPlayer: audioPlayer,
                                            audioURL: url,
                                            isEditing: false
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        .padding()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        
                    }
                    .background(AppColors.background)
                    .defaultTextColor()
                }
                
            
       
        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(showProfileMenuView: .constant(false))
//    }
//}
