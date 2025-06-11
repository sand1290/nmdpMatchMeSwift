
import SwiftUI

struct ShippingAddressView: View {
    @State private var fullName = ""
    @State private var streetAddress = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var phoneNumber = ""

    var body: some View {
        Form {
            Section(header: Text("Shipping Address")) {
                TextField("Full Name", text: $fullName)
                TextField("Street Address", text: $streetAddress)
                TextField("City", text: $city)
                TextField("State", text: $state)
                TextField("ZIP Code", text: $zipCode)
                TextField("Phone Number", text: $phoneNumber)
            }

            Section {
                Button("Submit") {
                    // Submit action here
                }
            }
        }
        .navigationTitle("Enter Address")
    }
}
