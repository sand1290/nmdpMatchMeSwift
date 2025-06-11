
import SwiftUI

struct AiChatView: View {
    @State private var input = ""
    @State private var messages: [String] = [
        "Hi! Ask me anything about your HLA type."
    ]

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.self) { message in
                    Text(message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            HStack {
                TextField("Ask something...", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    messages.append(input)
                    messages.append("AI: Here's what I found about \(input)...")
                    input = ""
                }
            }.padding()
        }
        .navigationTitle("Ask AI")
    }
}
