
import SwiftUI

struct HlaResultView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Your HLA Type:")
            Text("B*57:01")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.purple)

            Text("Estimated Match Likelihood: 3.2%")
                .font(.title2)
                .foregroundColor(.green)

            Text("This HLA type is common in:")
            Text("West African ancestry").bold()

            NavigationLink("Drug Reactions", destination: DrugInteractionView())
            NavigationLink("Ask AI", destination: AiChatView())

            Spacer()
        }
        .padding()
        .navigationTitle("HLA Results")
    }
}
