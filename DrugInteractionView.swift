
import SwiftUI

struct DrugInteractionView: View {
    let drugs = [
        ("Abacavir", "Severe hypersensitivity", "High"),
        ("Allopurinol", "Stevens-Johnson Syndrome", "Medium"),
        ("Carbamazepine", "Skin rash", "Low")
    ]

    var body: some View {
        List(drugs, id: \.0) { drug in
            HStack {
                VStack(alignment: .leading) {
                    Text(drug.0).bold()
                    Text(drug.1).font(.subheadline)
                }
                Spacer()
                Text(drug.2)
                    .padding(6)
                    .background(severityColor(drug.2))
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
