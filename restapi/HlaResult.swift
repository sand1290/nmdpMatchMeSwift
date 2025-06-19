//
//  HlaResult.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-16.
//

import Foundation

struct HlaResult: Codable, Identifiable {
    let id: UUID
    let hlaType: String
    let commonAncestry: String
    let matchProbability: String
    let drugInteractions: [DrugInteraction]
}
