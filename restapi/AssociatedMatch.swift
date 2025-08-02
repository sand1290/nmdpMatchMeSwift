//
//  RelatedMatch.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-08-01.
//

import Foundation
import CoreLocation

struct AssociatedMatch: Codable, Identifiable {
    let id: UUID
    let coordinate: LocationCoordinate
}
