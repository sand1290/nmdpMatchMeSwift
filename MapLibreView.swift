//
//  MapLibreView.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-14.
//

import MapLibre
import MapLibreSwiftUI
import MapLibreSwiftDSL
import MapKit
import SwiftUI

public struct MapLibreView: View {
    @StateObject private var locationDataManager = LocationDataManager()
    @State var camera: MapViewCamera = .default()

    var styleURL: URL?
    
    let CIRCLE_LAYER_ID = "simple-circles"
    let SYMBOL_LAYER_ID = "simple-symbols"
    
    // Careful, this is a secret
    let apiKey = "ce5af383-d261-4aa2-ae43-2e3fd2d33f37"
    
    // You can find other styles in our library (https://docs.stadiamaps.com/themes/) or
    // provide your own.
    let styleID = "osm_bright"
    
    // Simulated locations of other matched donors
    let coordinateGroup = [
        CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.3719),
        CLLocationCoordinate2D(latitude: 48.3082, longitude: 16.3719),
        CLLocationCoordinate2D(latitude: 48.2082, longitude: 16.9719),
        CLLocationCoordinate2D(latitude: 48.0082, longitude: 17.9719)
    ]
    
    // Patient location
    let patientCoordinate = CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816)

    init() {
        // Build the style URL
        styleURL = URL(string: "https://tiles.stadiamaps.com/styles/\(styleID).json?api_key=\(apiKey)")
    }
    
    public var body: some View {
        switch locationDataManager.authorizationStatus {
        case .authorizedWhenInUse:
            if locationDataManager.location != nil {
                // Shape source for other matched donors
                let clustered = ShapeSource(identifier: "points", options: [.clustered: true, .clusterRadius: 30]) {
                    for coordinate in coordinateGroup {
                        MLNPointFeature(coordinate: coordinate)
                    }
                }
                
                MapView(styleURL: styleURL!, camera: $camera) {
                    // Cluster == YES shows only those pins that are clustered, using .text
                    CircleStyleLayer(identifier: "simple-circles-clusters", source: clustered)
                        .radius(expression: NSExpression(format: "13"))
                        .color(.systemTeal)
                        .strokeWidth(1.5)
                        .strokeColor(.white)
                        .predicate(NSPredicate(format: "cluster == YES"))
                    
                    SymbolStyleLayer(identifier: "simple-symbols-clusters", source: clustered)
                        .textColor(.black)
                        .text(expression: NSExpression(format: "CAST(point_count, 'NSString')"))
                        .predicate(NSPredicate(format: "cluster == YES"))
                    
                    // Cluster != YES shows only those pins that are not clustered, using an icon
                    CircleStyleLayer(identifier: "simple-circles-non-clusters", source: clustered)
                        .radius(13)
                        .color(.systemTeal)
                        .strokeWidth(1.5)
                        .strokeColor(.white)
                        .predicate(NSPredicate(format: "cluster != YES"))
                    
                    SymbolStyleLayer(identifier: "simple-symbols-non-clusters", source: clustered)
                        .iconImage(UIImage(systemName: "mappin")!.withRenderingMode(.alwaysTemplate))
                        .iconColor(.black)
                        .predicate(NSPredicate(format: "cluster != YES"))
                    
                    if let meLoc = locationDataManager.location {
                        // Donor location marker
                        let meShapeSource = ShapeSource(identifier: "me") {
                            MLNPointFeature(coordinate: meLoc.coordinate)
                        }
                        
                        CircleStyleLayer(identifier: "simple-me-circle", source: meShapeSource)
                            .radius(8)
                            .color(.systemGreen)
                            .strokeWidth(1.5)
                            .strokeColor(.white)
                    }
                    
                    // Patient location marker
                    let patientShapeSource = ShapeSource(identifier: "patient") {
                        MLNPointFeature(coordinate: patientCoordinate)
                    }
                    
                    CircleStyleLayer(identifier: "simple-patient-circle", source: patientShapeSource)
                        .radius(10)
                        .color(.systemRed)
                        .strokeWidth(1.5)
                        .strokeColor(.white)

                }
                .onTapMapGesture(on: ["simple-circles-non-clusters"], onTapChanged: { _, features in
                    print("Tapped on \(features.first?.debugDescription ?? "<nil>")")
                })
                .expandClustersOnTapping(clusteredLayers: [ClusterLayer(
                    layerIdentifier: "simple-circles-clusters",
                    sourceIdentifier: "points")])
                .ignoresSafeArea(.all)
                .onAppear {
                    // Adjust the virtual camera so that all points are within the view
                    var allCoordinates: [CLLocationCoordinate2D] = []
                    allCoordinates.append(contentsOf: coordinateGroup)
                    allCoordinates.append(locationDataManager.location!.coordinate)
                    
                    camera = .boundingBox(allCoordinates.swne())
                }
            } else {
                ProgressView()
            }
            
        case .restricted, .denied:
            Text("Location was restricted or denied")
            
        case .notDetermined:
            Text("Determining location...")
            ProgressView()
            
        default:
            ProgressView()
        }
    }
}

#Preview {
    MapLibreView()
}

extension Array where Element == CLLocationCoordinate2D {
    // Finds the center of a bounding box enclosing all of the points
    func center() -> CLLocationCoordinate2D {
        var maxLatitude: Double = -.greatestFiniteMagnitude
        var maxLongitude: Double = -.greatestFiniteMagnitude
        var minLatitude: Double = .greatestFiniteMagnitude
        var minLongitude: Double = .greatestFiniteMagnitude

        for location in self {
            maxLatitude = Swift.max(maxLatitude, location.latitude)
            maxLongitude = Swift.max(maxLongitude, location.longitude)
            minLatitude = Swift.min(minLatitude, location.latitude)
            minLongitude = Swift.min(minLongitude, location.longitude)
        }

        let centerLatitude = CLLocationDegrees((maxLatitude + minLatitude) * 0.5)
        let centerLongitude = CLLocationDegrees((maxLongitude + minLongitude) * 0.5)
        return .init(latitude: centerLatitude, longitude: centerLongitude)
    }
    
    func swne() -> MLNCoordinateBounds {
        // Returns a bounding box containing all of the points
        var maxLatitude: Double = -.greatestFiniteMagnitude
        var maxLongitude: Double = -.greatestFiniteMagnitude
        var minLatitude: Double = .greatestFiniteMagnitude
        var minLongitude: Double = .greatestFiniteMagnitude

        for location in self {
            maxLatitude = Swift.max(maxLatitude, location.latitude)
            maxLongitude = Swift.max(maxLongitude, location.longitude)
            minLatitude = Swift.min(minLatitude, location.latitude)
            minLongitude = Swift.min(minLongitude, location.longitude)
        }

        let sw = CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude)
        let ne = CLLocationCoordinate2D(latitude: maxLatitude, longitude: maxLongitude)
        
        return MLNCoordinateBounds(sw: sw, ne: ne)
    }
}
