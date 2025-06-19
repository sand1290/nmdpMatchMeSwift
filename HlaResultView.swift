
import SwiftUI

struct HlaResultView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    @State var hlaResult: HlaResult = HlaResult(id: UUID(), hlaType: "", commonAncestry: "", matchProbability: "0", drugInteractions: [])
    @State var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Your HLA Type:")
                Text(hlaResult.hlaType)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.purple)
                
                Text("Estimated Match Likelihood: \(String(describing: hlaResult.matchProbability))%")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("This HLA type is common in:")
                Text("\(hlaResult.commonAncestry) ancestry").bold()
                
                NavigationLink("Drug Reactions", destination: DrugInteractionView(drugInteractions: hlaResult.drugInteractions))
                NavigationLink("Ask AI", destination: AiChatView())
                
                NavigationLink("Map", destination: MapLibreView())
                Spacer()
            }
            .padding()
            .navigationTitle("HLA Results")
            .onAppear {
                fetchHlaResults()
            }
            .overlay(isLoading ? ProgressView() : nil)
        }
    }
    
    func fetchHlaResults() {
        let apiService = APIService()
        apiService.fetchHlaResults(from: "/donor/hla/" + appDelegate.deviceTokenString) { hlaResult in
            DispatchQueue.main.async {
                self.hlaResult = hlaResult ?? HlaResult(id: UUID(), hlaType: "", commonAncestry: "", matchProbability: "0", drugInteractions: [])
                self.isLoading = false
            }
        }
    }
}

#Preview {
    HlaResultView()
}
