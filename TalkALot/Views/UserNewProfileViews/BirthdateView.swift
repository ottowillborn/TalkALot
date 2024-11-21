//
//  BirthdateView.swift
//  TalkALot
//
//  Created by Ryo Tabata on 2024-07-28.
//
//add must be over certain age

import SwiftUI

struct BirthdateView: View {
    @State private var birthdate = Date()
    let email: String
    let password: String
    @Binding var name: String

    var body: some View {
        VStack {
            Spacer()
            Text("Select Birthdate")
                .font(.largeTitle)
                .padding(.bottom,60)
            
            DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .frame(maxWidth: 300)
            
            NavigationLink(destination: EnterUserNameScreen(email: email, password: password, name: $name, birthdate: $birthdate)) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
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
//struct BirthdateView_Previews: PreviewProvider {
//    static var previews: some View {
//        //BirthdateView()
//    }
//}

