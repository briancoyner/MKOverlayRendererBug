//
//  Created by Brian Coyner on 3/12/22.
//

import Foundation
import UIKit
import MapKit

/// See the `readme` file for different testing scenarios.

final class MapViewController: UIViewController, MKMapViewDelegate {

    private lazy var annotations = lazyMagicKingdomAnnotations()
    private lazy var mapView = lazyMapView()
    private lazy var gridOverlay = lazyGridOverlay()
}

extension MapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Overlay Rendering Bug"
        showToolbarWithDemoButtons()

        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)

        // This demo uses the open streets to replace the standard base map tiles. Any `MKTileOverlay`
        // will expose the re-draw/ flickering bug.
        //
        // https://www.openstreetmap.org/copyright
        let tileOverlay = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        tileOverlay.canReplaceMapContent = true
        mapView.addOverlay(tileOverlay)

        // See `DelayedGridOverlayRenderer`.
        mapView.addOverlay(gridOverlay)
    }
}

// MARK: MKMapViewDelegate (Annotation View)

extension MapViewController {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let tileOverlay as MKTileOverlay:
            // Note: Replace the `MKTileOverlayRenderer` with the `HackTileOverlayRenderer` to stop re-drawing madness.
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            // return HackTileOverlayRenderer(tileOverlay: tileOverlay)
        case is GridOverlay:
            return DelayedGridOverlayRenderer()
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKUserLocation:
            return nil
        default:
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
        }
    }
}

extension MapViewController {

    @objc
    private func addGridOverlay() {
        guard !(mapView.overlays.contains { $0 === gridOverlay }) else {
            return
        }

        mapView.addOverlay(gridOverlay)
    }

    @objc
    private func removeGridOverlay() {
        mapView.removeOverlay(gridOverlay)
    }
}

extension MapViewController {

    private func showToolbarWithDemoButtons() {
        setToolbarItems([
            UIBarButtonItem(title: "Add Grid", style: .plain, target: self, action: #selector(addGridOverlay)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Remove Grid", style: .plain, target: self, action: #selector(removeGridOverlay))
        ], animated: false)

        navigationController?.setToolbarHidden(false, animated: false)
    }
}

extension MapViewController {

    private func lazyGridOverlay() -> GridOverlay {
        return GridOverlay()
    }

    private func lazyMapView() -> MKMapView {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.mapType = .satellite
        view.delegate = self

        return view
    }
}

extension MapViewController {

    private func lazyMagicKingdomAnnotations() -> [MKAnnotation] {
        return [
            makeAnnotation(
                withTitle: "It's a Small World",
                coordinate: CLLocationCoordinate2D(latitude: 28.420827, longitude: -81.581957)
            ),
            makeAnnotation(
                withTitle: "Splash Mountain",
                coordinate: CLLocationCoordinate2D(latitude: 28.419215, longitude: -81.585046)
            ),
            makeAnnotation(
                withTitle: "Seven Dwarfs Mine Train",
                coordinate: CLLocationCoordinate2D(latitude: 28.4205, longitude: -81.5801)
            ),
            makeAnnotation(
                withTitle: "Under the Sea",
                coordinate: CLLocationCoordinate2D(latitude: 28.421199, longitude: -81.579966)
            ),
            makeAnnotation(
                withTitle: "Space Mountain",
                coordinate: CLLocationCoordinate2D(latitude: 28.4191, longitude: -81.5771)
            ),
            makeAnnotation(
                withTitle: "Pirates of the Caribbean",
                coordinate: CLLocationCoordinate2D(latitude: 28.4181, longitude: -81.5846)
            )
        ]
    }

    private func makeAnnotation(withTitle title: String, coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title

        return annotation
    }
}
