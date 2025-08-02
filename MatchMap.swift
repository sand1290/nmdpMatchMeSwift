import SwiftUI
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let color: Color
}

struct MatchMap: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    @State private var cameraPosition = MapCameraPosition.automatic
    @State var relatedMatches: AssociatedMatchesResult = .init(associatedMatches: [])
    @State var isLoading: Bool = true
    @State var coordinateGroup: [CLLocationCoordinate2D] = []

    var body: some View {
        ClusteredMapView(coordinates: $coordinateGroup, appDelegate: appDelegate)
            .onAppear {
                fetchAssociatedMatches()
            }
            .overlay(isLoading ? ProgressView() : nil)
    }
    
    func fetchAssociatedMatches() {
        let apiService = APIService()
        apiService.fetchAssociatedMatches(for: appDelegate.deviceTokenString) { associatedMatchesResult in
            DispatchQueue.main.async {
                self.relatedMatches = associatedMatchesResult ?? AssociatedMatchesResult(associatedMatches: [])
                self.coordinateGroup = associatedMatchesResult?.associatedMatches.map { CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) } ?? []
                self.isLoading = false
            }
        }
    }
}

// MARK: - UIKit MapView with Clustering Support
struct ClusteredMapView: UIViewRepresentable {
    @Binding var coordinates: [CLLocationCoordinate2D]

    let appDelegate: AppDelegate
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.mapType = .hybridFlyover
        
        // User Location Button
        let userLocationButton = MapAccessoryButton(systemImageName: "location.fill", target: context.coordinator, action: #selector(ClusteredMapView.Coordinator.centerOnUser))
        mapView.addSubview(userLocationButton)
        NSLayoutConstraint.activate([
            userLocationButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            userLocationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            userLocationButton.widthAnchor.constraint(equalToConstant: 44),
            userLocationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Reset Region Button
        let resetRegionButton = MapAccessoryButton(systemImageName: "arrow.counterclockwise", target: context.coordinator, action: #selector(ClusteredMapView.Coordinator.resetRegion))
        mapView.addSubview(resetRegionButton)
        NSLayoutConstraint.activate([
            resetRegionButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            resetRegionButton.bottomAnchor.constraint(equalTo: userLocationButton.topAnchor, constant: -12),
            resetRegionButton.widthAnchor.constraint(equalToConstant: 44),
            resetRegionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Reset Region (All) Button
        let resetAllRegionButton = MapAccessoryButton(systemImageName: "scope", target: context.coordinator, action: #selector(ClusteredMapView.Coordinator.resetAllRegion))
        mapView.addSubview(resetAllRegionButton)
        NSLayoutConstraint.activate([
            resetAllRegionButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            resetAllRegionButton.bottomAnchor.constraint(equalTo: resetRegionButton.topAnchor, constant: -12),
            resetAllRegionButton.widthAnchor.constraint(equalToConstant: 44),
            resetAllRegionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Enable clustering
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add new annotations
        let annotations = coordinates.enumerated().map { index, coordinate in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            return annotation
        }
        
        mapView.addAnnotations(annotations)
        
        // Always update region when coordinates change
        if !coordinates.isEmpty {
            context.coordinator.updateRegionWithNewCoordinates()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        weak var mapView: MKMapView?
        private var didSetInitialRegion = false
        private var userLocationAvailable = false
        private var currentRegionMode: RegionMode = .automatic
        
        enum RegionMode {
            case automatic
            case userLocationOnly
            case markersOnly
            case allMarkers
        }
        
        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location annotation
            if annotation is MKUserLocation {
                return nil
            }
            
            if let cluster = annotation as? MKClusterAnnotation {
                // Custom cluster view
                let identifier = "cluster"
                var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if clusterView == nil {
                    clusterView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                }
                clusterView?.markerTintColor = .blue
                clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
                
                // Add tap gesture to expand cluster
                clusterView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clusterTapped(_:))))
                
                return clusterView
            }
            
            // Individual marker
            let identifier = "marker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView?.markerTintColor = .red
            annotationView?.glyphText = "•"
            annotationView?.titleVisibility = .visible
            annotationView?.clusteringIdentifier = "cluster"
            return annotationView
        }
        
        @objc func clusterTapped(_ gesture: UITapGestureRecognizer) {
            guard let annotationView = gesture.view as? MKAnnotationView,
                  let cluster = annotationView.annotation as? MKClusterAnnotation,
                  let mapView = self.mapView else {
                return
            }
            
            // Calculate region that shows all cluster members
            let coordinates = cluster.memberAnnotations.map { $0.coordinate }
            let region = MKCoordinateRegion(coordinates: coordinates)

            // Animate to the new region
            mapView.setRegion(region, animated: true)
        }
        
        @objc func centerOnUser() {
            guard let mapView = self.mapView,
                  let userLocation = mapView.userLocation.location else { return }
            currentRegionMode = .userLocationOnly
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        @objc func resetRegion() {
            guard let mapView = self.mapView else { return }
            currentRegionMode = .markersOnly
            let region = MKCoordinateRegion(coordinates: parent.coordinates, paddingFactor: 1.2).clamped()
            mapView.setRegion(region, animated: true)
            
            // Force refresh of annotation views after region change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Remove and re-add annotations to force refresh
                let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
                mapView.removeAnnotations(annotations)
                mapView.addAnnotations(annotations)
            }
        }
        
        @objc func resetAllRegion() {
            guard let mapView = self.mapView else { return }
            currentRegionMode = .allMarkers
            var allCoordinates = parent.coordinates
            if let userLocation = mapView.userLocation.location {
                allCoordinates.append(userLocation.coordinate)
            }
            let region = MKCoordinateRegion(coordinates: allCoordinates, paddingFactor: 1.2).clamped()
            mapView.setRegion(region, animated: true)
            
            // Force refresh of annotation views after region change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Remove and re-add annotations to force refresh
                let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
                mapView.removeAnnotations(annotations)
                mapView.addAnnotations(annotations)
            }
        }
        
        func updateRegionWithNewCoordinates() {
            // Only update region if in automatic mode
            guard currentRegionMode == .automatic else { return }
            
            guard let mapView = self.mapView else { return }
            
            // If user location is available, include it in the region
            if userLocationAvailable, let userLocation = mapView.userLocation.location {
                var allCoordinates = parent.coordinates
                allCoordinates.append(userLocation.coordinate)
                let region = MKCoordinateRegion(coordinates: allCoordinates, paddingFactor: 1.2).clamped()
                mapView.setRegion(region, animated: true)
            } else if !parent.coordinates.isEmpty {
                // User location not available yet, set region for coordinates only
                let region = MKCoordinateRegion(coordinates: parent.coordinates, paddingFactor: 1.2).clamped()
                mapView.setRegion(region, animated: true)
            }
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            userLocationAvailable = true
            
            // Only set initial region if in automatic mode
            if currentRegionMode == .automatic {
                // If coordinates are already available, update region to include both
                if !parent.coordinates.isEmpty {
                    updateRegionWithNewCoordinates()
                } else if !didSetInitialRegion {
                    // Set initial region with just user location if no coordinates yet
                    didSetInitialRegion = true
                    let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(region, animated: false)
                }
            }
        }
    }
}

// MARK: - CMV helpers
extension ClusteredMapView {
    class MapAccessoryButton: UIButton {
        // Allow passing in the system image name and optionally a target/action
        convenience init(systemImageName: String, target: Any?, action: Selector) {
            self.init(type: .system)
            configureStyle()
            setImage(UIImage(systemName: systemImageName), for: .normal)
            addTarget(target, action: action, for: .touchUpInside)
        }

        private func configureStyle() {
            tintColor = .systemBlue
            backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
            layer.cornerRadius = 22
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
// MARK: - Helper Extension
extension MKCoordinateRegion {
    init(coordinates: [CLLocationCoordinate2D], paddingFactor: Double = 4.0) {
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * paddingFactor,
            longitudeDelta: (maxLon - minLon) * paddingFactor
        )
        
        self.init(center: center, span: span)
    }
    
    init(coordinates: [CLLocationCoordinate2D], latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        guard !coordinates.isEmpty else {
            self.init()
            return
        }
        
        let center = coordinates.reduce(CLLocationCoordinate2D(latitude: 0, longitude: 0)) { result, coordinate in
            CLLocationCoordinate2D(
                latitude: result.latitude + coordinate.latitude,
                longitude: result.longitude + coordinate.longitude
            )
        }
        
        let avgCenter = CLLocationCoordinate2D(
            latitude: center.latitude / Double(coordinates.count),
            longitude: center.longitude / Double(coordinates.count)
        )
        
        self.init(
            center: avgCenter,
            latitudinalMeters: latitudinalMeters,
            longitudinalMeters: longitudinalMeters
        )
    }

    func clamped(maxLatitudeDelta: CLLocationDegrees = 90, maxLongitudeDelta: CLLocationDegrees = 180) -> MKCoordinateRegion {
        let clampedSpan = MKCoordinateSpan(
            latitudeDelta: min(self.span.latitudeDelta, maxLatitudeDelta),
            longitudeDelta: min(self.span.longitudeDelta, maxLongitudeDelta)
        )
        return MKCoordinateRegion(center: self.center, span: clampedSpan)
    }
}

