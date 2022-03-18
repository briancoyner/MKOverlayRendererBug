//
//  Created by Brian Coyner on 3/12/22.
//

import MapKit

final class GridOverlay: NSObject, MKOverlay {

    @objc dynamic
    var color: UIColor = .systemBlue

    var boundingMapRect: MKMapRect {
        return .world
    }

    var coordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: boundingMapRect.midX, y: boundingMapRect.midY).coordinate
    }
}
