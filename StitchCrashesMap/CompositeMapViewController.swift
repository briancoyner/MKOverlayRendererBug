//
//  Created by Brian Coyner on 3/18/22.
//

import UIKit
import MapKit

final class CompositeMapViewController: UIViewController {

    private lazy var annotations = lazyMagicKingdomAnnotations()
    private lazy var grid = lazyGrid()
    private lazy var baseMap = lazyBaseMap()



    override func viewDidLoad() {
        super.viewDidLoad()

        showToolbarWithDemoButtons()

        let one = MapViewController(annotations: annotations, grid: grid, baseMap: baseMap)
        let two = MapViewController(annotations: annotations, grid: grid, baseMap: baseMap)

        addChild(one)
        addChild(two)

        let stackView = UIStackView(arrangedSubviews: [
            one.view!,
            two.view!
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        one.didMove(toParent: self)
        two.didMove(toParent: self)
    }
}

extension CompositeMapViewController {

    @objc
    private func userWantsToChangeColor() {
        let colors: [UIColor] = [
            .systemBlue,
            .systemRed,
            .systemOrange,
            .systemGreen
        ]

        grid.0.color = colors.randomElement()!
    
//        gridRenderer.setNeedsDisplay()
    }

//    @objc
//    private func addGridOverlay() {
//        guard !(mapView.overlays.contains { $0 === gridOverlay }) else {
//            return
//        }
//
//        mapView.addOverlay(gridOverlay)
//    }
//
//    @objc
//    private func removeGridOverlay() {
//        mapView.removeOverlay(gridOverlay)
//    }
}

extension CompositeMapViewController {

    private func showToolbarWithDemoButtons() {
        setToolbarItems([
//            UIBarButtonItem(title: "Add Grid", style: .plain, target: self, action: #selector(addGridOverlay)),
            UIBarButtonItem(title: "Change Color", style: .plain, target: self, action: #selector(userWantsToChangeColor)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(title: "Remove Grid", style: .plain, target: self, action: #selector(removeGridOverlay))
        ], animated: false)

        navigationController?.setToolbarHidden(false, animated: false)
    }
}

extension CompositeMapViewController {

    func lazyMagicKingdomAnnotations() -> [MKAnnotation] {
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

    private func lazyGrid() -> (GridOverlay, ((GridOverlay) -> DelayedGridOverlayRenderer)) {
        let grid = GridOverlay()
        let renderer = DelayedGridOverlayRenderer(overlay: grid)
        return (grid, { _ in renderer })
    }

    private func lazyBaseMap() -> (MKTileOverlay, ((MKTileOverlay) -> MKTileOverlayRenderer)) {
        let baseMap = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        baseMap.canReplaceMapContent = true

        return (baseMap, {
            HackTileOverlayRenderer(overlay: $0)
        })
    }

    private func makeAnnotation(withTitle title: String, coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title

        return annotation
    }
}
