//
//  Created by Brian Coyner on 3/12/22.
//

import Foundation
import UIKit
import MapKit

/// See the `readme` file for different testing scenarios.

final class MapViewController: UIViewController, MKMapViewDelegate {

    private let annotations: [MKAnnotation]
    private let grid: (GridOverlay, ((GridOverlay) -> DelayedGridOverlayRenderer))
    private let baseMap: (MKTileOverlay, ((MKTileOverlay) -> MKTileOverlayRenderer))

    private lazy var mapView = lazyMapView()

    init(
        annotations: [MKAnnotation],
        grid: (GridOverlay, ((GridOverlay) -> DelayedGridOverlayRenderer)),
        baseMap: (MKTileOverlay, ((MKTileOverlay) -> MKTileOverlayRenderer))
    ) {
        self.annotations = annotations
        self.grid = grid
        self.baseMap = baseMap

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Overlay Rendering Bug"


        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: false)

        mapView.addOverlay(baseMap.0)
        mapView.addOverlay(grid.0)
    }
}

// MARK: MKMapViewDelegate (Annotation View)

extension MapViewController {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let tileOverlay as MKTileOverlay:
            // Note: Replace the `MKTileOverlayRenderer` with the `HackTileOverlayRenderer` to stop re-drawing madness.
            return baseMap.1(tileOverlay)
        case let gridOverlay as GridOverlay:
            return grid.1(gridOverlay)
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
