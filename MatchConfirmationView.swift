//
//  MatchConfirmationView 2.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Jason Brelsford on 6/4/25.
//



import SwiftUI

struct MatchConfirmationView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("🎉 You're a Match!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            Text("Thank you for your quick response. Your response has increased your chances of being a donor for this life saving treatment.")
                .multilineTextAlignment(.center)

            Text("We’ll be in touch to inform you if you’re needed for activation.")
                .multilineTextAlignment(.center)
                .padding(.top)

            Text("We appreciate you being a part of our mission to save a life.")
                .multilineTextAlignment(.center)
                .foregroundColor(.blue)
                .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Thank You")
    }
}

