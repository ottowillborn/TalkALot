//
//  BirthdateView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//

import SwiftUI

struct BirthdateView: View {
    @State private var birthdate = Date()

    var body: some View {
        VStack {
            Text("Select your birthdate")
                .font(.largeTitle)
                .padding()
            
            DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .frame(maxWidth: 300)
            
            NavigationLink(destination: EnterUserNameScreen().onAppear(perform: saveBirthdate)) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }

    func saveBirthdate() {
        UserDefaults.standard.set(birthdate, forKey: "userBirthdate")
    }
}
struct BirthdateView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdateView()
    }
}

