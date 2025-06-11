
import SwiftUI

struct MatchAlertView: View {
    @Environment(\.presentationMode) var presentationMode
    var onResponse: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("🚨 You’re a potential match!")
                .font(.title)
                .bold()
            Text("Are you still in?")
                .font(.headline)

            HStack(spacing: 20) {
                Button("Not Ever") {
                    onResponse("never")
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)

                Button("Not Now") {
                    onResponse("not_now")
                    presentationMode.wrappedValue.dismiss()
                }

                Button("Yes") {
                    onResponse("yes")
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.green)
            }
        }
        .padding()
    }
}

