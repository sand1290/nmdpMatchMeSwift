
import SwiftUI

struct DrugInteractionView: View {
    @State var drugInteractions: [DrugInteraction]
    
    var body: some View {
        List($drugInteractions) { drugInteraction in
            HStack {
                VStack(alignment: .leading) {
                    Text(drugInteraction.wrappedValue.name)
                    Text(drugInteraction.wrappedValue.condition).font(.subheadline)
                }
                Spacer()
                Text(drugInteraction.wrappedValue.reactionLevel)
                    .padding(6)
                    .background(severityColor(drugInteraction.wrappedValue.reactionLevel))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
        }
        .navigationTitle("Drug Reactions")
    }

    func severityColor(_ severity: String) -> Color {
        switch severity {
            case "High": return .red
            case "Medium": return .orange
            default: return .gray
        }
    }
}

#Preview {
    DrugInteractionView(drugInteractions: [])
}
