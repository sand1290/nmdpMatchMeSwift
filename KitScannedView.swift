import SwiftUI

struct KitScannedView: View {
    var kitCode: String

    var body: some View {
        let parsed = parseKitCode(kitCode)
        VStack(spacing: 24) {
            Text("✅ Kit Scanned")
                .font(.largeTitle)
                .bold()

            Text("Name: \(parsed.name)")
            Text("Drive: \(parsed.drive)")

            Link("Watch Swab Instructions",
                 destination: URL(string: "https://youtube.com/shorts/-8SH77tQJpI?si=690zhzrbtmGmF05t")!)
                .foregroundColor(.blue)
                .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Kit Info")
    }

    func parseKitCode(_ code: String) -> (name: String, drive: String) {
        let parts = code.split(separator: ";").reduce(into: [String: String]()) { dict, pair in
            let keyValue = pair.split(separator: "=")
            if keyValue.count == 2 {
                dict[String(keyValue[0])] = String(keyValue[1])
            }
        }
        return (parts["name"] ?? "John Doe", parts["drive"] ?? "SaveMoreDonors")
    }
}
