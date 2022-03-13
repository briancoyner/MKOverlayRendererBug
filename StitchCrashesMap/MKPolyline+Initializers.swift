//
//  Created by Brian Coyner on 3/12/22.
//

import MapKit

extension MKPolyline {

    convenience init(coordinates: [CLLocationCoordinate2D]) {
        var internalCoordinates = coordinates
        self.init(coordinates: &internalCoordinates, count: coordinates.count)
    }
}
