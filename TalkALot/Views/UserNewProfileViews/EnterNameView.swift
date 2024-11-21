//
//  EnterNameView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI


struct EnterNameView: View {
    @State private var name: String = ""
    let email: String
    let password: String
    var body: some View {
        VStack {
            Text("What is your name?")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: 300)
            
            NavigationLink(destination: BirthdateView(email: email, password: password, name: $name)) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

}



//struct EnterNameView_Previews: PreviewProvider {
//    static var previews: some View {
//        //EnterNameView()
//    }
//}
