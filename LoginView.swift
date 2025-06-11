import SwiftUI

struct LoginView: View {
    @State private var showScanner = false
    @State private var scannedKitCode: String = ""
    @State private var showKitInfo = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // QR Scanner Button
                Button(action: {
                    showScanner = true
                }) {
                    Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }

                Spacer()

                Button("Continue with Google") {
                    // Google login action
                }
                .buttonStyle(.borderedProminent)

                Button("Continue with Apple") {
                    // Apple login action
                }
                .buttonStyle(.bordered)

                Button("Continue with TikTok") {
                    // TikTok login action
                }
                .buttonStyle(.bordered)

                Spacer()

                NavigationLink("Start Match Process", destination: MatchLikelihoodView())

                Link("Feed", destination: URL(string: "https://youtube.com/shorts/-8SH77tQJpI?si=690zhzrbtmGmF05t")!)
                    .foregroundColor(.blue)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showScanner) {
                QRScannerView { result in
                    scannedKitCode = result
                    showScanner = false
                    showKitInfo = true
                }
            }
            .navigationDestination(isPresented: $showKitInfo) {
                KitScannedView(kitCode: scannedKitCode)
            }
        }
    }
}


