//
//  EnterNameView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI


struct EnterNameView: View {
    @State private var name: String = ""

    var body: some View {
        VStack {
            Text("What is your name?")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: 300)
            
            NavigationLink(destination: BirthdateView().onAppear(perform: saveName)) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    func saveName() {
        UserDefaults.standard.set(name, forKey: "userName")
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNameView()
    }
}
