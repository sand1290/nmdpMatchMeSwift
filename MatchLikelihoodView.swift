
import SwiftUI

struct MatchLikelihoodView: View {
    @State private var showKitConfirmation = false
    @State private var showRequestConfirmation = false
    @State private var showMatchAlert = false
    @State private var navigateToConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Your current match probability is:")
                Text("1%")
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                    .bold()

                Button("Improve Your Match Possibility") {
                    showKitConfirmation = true
                }
                .buttonStyle(.borderedProminent)

                Button("Request a Swab Kit") {
                    showRequestConfirmation = true
                }
                .buttonStyle(.bordered)

                Text("You can improve your odds by completing HLA typing using our free swab kit.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)

                Spacer()

                Button("Simulate Match Notification") {
                    showMatchAlert = true
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("View HLA Results", destination: HlaResultView())
            }
            .padding()
            .alert("Typing Kit Requested", isPresented: $showKitConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("A free HLA typing kit will be mailed to you.")
            }
            .alert("Swab Kit Requested", isPresented: $showRequestConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We've received your swab kit request. Watch for it in the mail!")
            }
            .sheet(isPresented: $showMatchAlert) {
                MatchAlertView { response in
                    switch response {
                    case "yes", "not_now":
                        navigateToConfirmation = true
                    case "never":
                        print("User opted out permanently")
                    default:
                        break
                    }
                }
            }
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
//                    showMatchAlert = true
//                }
//            }
            .navigationDestination(isPresented: $navigateToConfirmation) {
                MatchConfirmationView()
            }
            .navigationTitle("Your Match")
        }
    }
}

#Preview {
    MatchLikelihoodView()
}
