//
//  DrugInteraction.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-16.
//

import Foundation

struct DrugInteraction: Codable, Identifiable {
    let id: UUID
    let name: String
    let condition: String
    let reactionLevel: String
}

